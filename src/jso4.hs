{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE FlexibleInstances #-}

import Data.List (lookup)
import Data.Maybe (fromMaybe)
import Prelude hiding ((.), concat)

type Name = String
type Prototype = Object
type Attribute' = Object
type Attribute = (Name, Attribute')
type This = Object
type Parameter = Object
type Method = This -> [Parameter] -> Object

data Object = Null | O [Attribute] Prototype | I [Attribute] Prototype Int |
              S [Attribute] Prototype String | M [Attribute] Prototype Method

instance Show Object where
    show o = getS ((o."toString")[])

getAs :: Object -> [Attribute]
getAs (O as _) = as
getAs (I as _ _) = as
getAs (S as _ _) = as
getAs (M as _ _) = as

getP :: Object -> Prototype
getP (O _ p) = p
getP (I _ p _) = p
getP (S _ p _) = p
getP (M _ p _) = p

getM :: Object -> Method
getM (M _ _ m) = m

getI :: Object -> Int
getI (I _ _ i) = i

getS :: Object -> String
getS (S _ _ s) = s
getS o = getS ((o."toString")[])

class New a where
    new :: a -> [Attribute] -> Object

instance New Prototype where
    new = flip O

instance New String where
    new s as = S as string s

instance New Int where
    new i as = I as int i

instance New Method where
    new m as = M as method m

object = O [("toString", newM toString)] Null
    where toString this _ = newS "Object"

int = new object [("toString", newM toString)
                 ,("add", newM add)
                 ]
    where toString this _ = newS (show (getI this))
          add this [that] = newI ((getI this) + (getI that))

string = new object [("toString", newM toString)
                    ,("length", newM leng)
                    ,("concat", newM concat)
                    ]
    where toString this _ = this
          leng this _ = newI (length (getS this))
          concat this [that] = newS ((getS this) ++ (getS that))

method = new object [("toString", newM toString)]
    where toString _ _ = newS "Method"

newI :: Int -> Object
newI i = new i []

newS :: String -> Object
newS s = new s []

newM :: Method -> Object
newM m = new m []

(.<) :: Object -> Name -> Object
o .< name = fromMaybe ((getP o) .< name) (lookup name (getAs o))

(.) :: Object -> Name -> [Parameter] -> Object
(.) o name ps = method o ps
    where method = getM (o .< name)

-- Examples ---

foo = newS "foo"
one = newI 1
two = newI 2
seven = (((two."add")[two])."add")[(foo."length")[]]
concat = "concat"
add = "add"

job = new object []

programmer = new job [("name", newS "Programmer")
                     ,("salary", newI 50000)
                     ,("toString", newM toString)
                     ]
    where toString this _ = ((((this.<"name").concat)[newS " @"].
                            concat)[this.<"salary"].
                            concat)[newS "$"]

person = new object [("toString", newM toString) -- for some functions you would have to add type annotations if you want to use new instead of newM
                    ,("name", newS "no name") -- new should always work for strings, but you save a [] this way
                    ,("age", new (0::Int) []) -- depending on your settings you might have to annotate Int in case you are not using newI
                    ,("haveBirthday", newM haveBirthday)
                    ,("greet", new greet [])
                    ,("setJob", newM setJob)
                    ]
    where toString this _ = (this.<"name")
          haveBirthday this _ = new this [("age", ((this.<"age").add)[one])]
          greet this [name] = (((((((newS "Hello ").concat)[name].
                              concat)[newS ". My name is "].
                              concat)[this.<"name"].
                              concat)[newS " and I'm "].
                              concat)[this.<"age"].
                              concat)[newS " years old."]
          setJob this [job] = new this [("job", job)]

bob = new person [("name", new "Bob" [])]
greeting = (bob."greet")[newS "John"] -- Hello John. My name is Bob and I'm 0 years old.
bob2 = (bob."haveBirthday")[]
greeting2 = (bob2."greet")[newS "John"] -- Hello John. My name is Bob and I'm 1 years old.
employedBob = (bob."setJob")[programmer]
bobsJob = employedBob.<"job" -- Programmer @50000$
p2 = new programmer [("toString", person.<"toString")] -- Programmer (the toString method of person only returns the name)
