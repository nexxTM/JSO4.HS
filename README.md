#JSO4.HS

Some JavaScript madness in Haskell. Don't use this! It just exists to
demonstrate that "dynamic languages" are a special case of "static languages" by
basically using the same *static type* for everything. In this case an EDSL
library to use JavaScript objects in Haskell. For Java there is a framework
called Spring (not to get JS, to get "dynamic language").

Yes, I know, this is not really like JavaScript. It is just a quick proof of
concept. [Close enough](https://www.google.de/search?q=close+enough&tbm=isch).

## Idiosyncrasies

* When you call a method you have to put the arguments in brackets [] instead
of parenthesis ()
* When you call a method you have to put the method name in quotes ""
  * Well you can cheat by creating a variable containing that string
* When you call a method you have to put the object and the method name in
parenthesis `(object."methodname")[argument1, argument2, ...]`
  * Fun fact: When doing a lot of method chaining this reminds me a bit of an
inverse Scheme, because I have to add a bunch of opening parenthesis in front
when I'm done.
* When you want to get an attribute of an object instead of calling it, you
have to use `.<` instead of `.`.
* The wrappers around the Haskell native data types are a bit special. Mostly
you want to use `new*` instead of `new` for them.

## FAQ

Q: "Dynamic Languages" are not compiled, they are interpreted!

A: That is not a question. Anyway, this is more of an implementation
detail. If you are using GHC, you can `runhaskell <yourScript>` to interpret it.

Q: My script does not type check. What should I do?

A: Did you try `new*`? Otherwise this should not happen when you are only using
jso4.hs objects. You could use [`-fdefer-type-errors`](https://www.haskell.org/ghc/docs/latest/html/users_guide/defer-type-errors.html)
to let GHC ignore those and produce runtime
errors when the execution hits the problem; like you are used to from your
favorite "dynamic language".

## Examples

```haskell
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

```