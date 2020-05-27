---
title:    Entangled
subtitle: Example literate programs
version:  1.0.0
footer:   "(C) 2020 Johan Hidding, Netherlands eScience Center"
license:  "[Apache 2](https://www.apache.org/licenses/LICENSE-2.0)"
---

# Examples
These demos show how you can use Literate Programming to document your code.

``` {.dhall .bootstrap-card-deck}
let Card = ./schema/Card.dhall

in [ Card :: { title = "Hello World"
             , text =
                ''
                Literate "Hello, World!" in **C++**. If you have never seen a literate program
                before, this is where to start.
                ''
             , link = Some { href = "hello-world.html"
                           , content = "Hello, World!" }
             , image = Some "img/hello-world-thumb.jpg"
             }
   , Card :: { title = "99 Bottles"
             , text =
                ''
                A heavily over-engineered drinking song generator in **C++**. Explains how to do
                simple argument parsing using `ArgAgg` and string formatting with `libfmt`.
                ''
             , link = Some { href = "99-bottles.html"
                           , content = "99 Bottles" }
             , image = Some "img/99-bottles-thumb.jpg"
             }
   , Card :: { title = "Slasher"
             , text =
                ''
                An action packed browser game, written in **Elm**! Our hero zips across the screen at break-neck speeds
                and you have to steer them to the golden snitch using only `/` and `\` characters.
                ''
             , link = Some { href = "slasher.html"
                           , content = "Slasher!" }
             , image = Some "img/slasher-thumb.jpg"
             }
   ]
```

``` {.dhall .bootstrap-card-deck}
let Card = ./schema/Card.dhall
in [ Card :: { title = "Chaotic Pendulum"
             , text =
                ''
                A physics demo, showing a model of a chaotic pendulum, written in **PureScript**.
                ''
             , link = Some { href = "https://jhidding.github.io/chaotic-pendulum/"
                           , content = "Chaotic Pendulum" }
             , image = Some "img/chaotic-pendulum-thumb.png"
             }
   ]
```

