-- ~\~ language=Elm filename=slasher/src/Main.elm
-- ~\~ begin <<lit/slasher.md|slasher/src/Main.elm>>[0]
module Main exposing (..)

-- ~\~ begin <<lit/slasher.md|imports>>[0]
import Browser
import Array exposing (Array, repeat, indexedMap, toList, set, get)
import List exposing (concat)
import Browser.Events exposing (onAnimationFrameDelta, onKeyDown)
import Html exposing (Html, button, div, text, p, input, main_, a)
import Html.Attributes exposing (href)
import Html.Events exposing (onClick, preventDefaultOn)
import Svg exposing (svg, circle, line, rect, g, polygon, text_)
import Svg.Attributes exposing (..)
import Random

import Json.Decode as Decode
-- ~\~ end
-- ~\~ begin <<lit/slasher.md|main>>[0]
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view }
-- ~\~ end

-- ~\~ begin <<lit/slasher.md|model>>[0]
type alias Model =
    { actors : { player : Actor, snitch : Actor }
    , grid : Grid
    , snitchTime : Float
    , state : GameState
    }
-- ~\~ end
-- ~\~ begin <<lit/slasher.md|model>>[1]
type GameState = Start | Running | Pause | Won
-- ~\~ end
-- ~\~ begin <<lit/slasher.md|model>>[2]
type alias Grid = Array (Array Cell)

type Cell
    = Empty
    | Slash
    | BackSlash

gridRef : (Int, Int) -> Grid -> Cell
gridRef (i, j) grid = 
    Maybe.withDefault Empty 
    <| Maybe.andThen (\ row -> get i row) (get j grid)

gridSet : (Int, Int) -> Cell -> Grid -> Grid
gridSet (i, j) cell grid =
    let row_ = get j grid
    in case row_ of
        Nothing  -> grid
        Just row -> set j (set i cell row) grid
-- ~\~ end
-- ~\~ begin <<lit/slasher.md|model>>[3]
type alias Actor =
    { location : (Float, Float)
    , velocity : (Float, Float)
    }
-- ~\~ end
-- ~\~ begin <<lit/slasher.md|model>>[4]
type alias Config =
    { gridSize : (Int, Int)
    , playerSpeed : Float
    , scale : Int
    , snitchTime : Float
    }

config : Config
config =
    { gridSize = (80, 50)
    , playerSpeed = 0.03
    , scale = 15
    , snitchTime = 10000
    }

inRange : (Int, Int) -> Bool
inRange (i, j) = 
    let (w, h) = config.gridSize
    in i >= 0 && i < w && j >= 0 && j < h
-- ~\~ end
-- ~\~ begin <<lit/slasher.md|model>>[5]
init : () -> (Model, Cmd Msg)
init _ = 
    let (width, height) = config.gridSize
        playerLoc       = ((toFloat width)/2 + 0.5, 2.5)
    in (
    { actors =
        { player = { location = playerLoc
                   , velocity = (0.0, config.playerSpeed) }
        , snitch = { location = (0.0, 0.0)
                   , velocity = (0.0, 0.0) }
        }
    , grid = makeGrid config.gridSize
    , snitchTime = 0.0
    , state = Start
    }, Random.generate
            PlaceSnitch
            (Random.pair (Random.int 0 (width - 1))
                         (Random.int 0 (height - 1))))

makeGrid : (Int, Int) -> Array (Array Cell)
makeGrid (width, height) =
    Array.repeat height
                 (Array.repeat width Empty)
-- ~\~ end
-- ~\~ begin <<lit/slasher.md|update>>[0]
-- ~\~ begin <<lit/slasher.md|msg-type>>[0]
type Msg
    = KeyPress String
    | TimeStep Float
    | PlaceSnitch (Int, Int)
-- ~\~ end
-- ~\~ begin <<lit/slasher.md|update-function>>[0]
update : Msg -> Model -> (Model, Cmd Msg)
-- ~\~ end
-- ~\~ begin <<lit/slasher.md|update-function>>[1]
update msg model =
    case msg of
        TimeStep dt   -> let next = timeStep dt model
                         in (next, checkSnitchTime next)
        KeyPress k    -> (keyMap k model, Cmd.none)
        PlaceSnitch l -> (placeSnitch l model, Cmd.none)
-- ~\~ end
-- ~\~ end
-- ~\~ begin <<lit/slasher.md|update>>[1]
timeStep : Float -> Model -> Model
timeStep dt ({actors, grid, snitchTime, state} as model) =
    case state of
        Running -> if didWeWin model
                   then { model
                        | state = Won }
                   else { model
                        | snitchTime = snitchTime - dt
                        , actors =
                            { actors
                            | player = updateActor grid dt actors.player } }
        _       -> model
-- ~\~ end
-- ~\~ begin <<lit/slasher.md|update>>[2]
didWeWin : Model -> Bool
didWeWin ({actors} as model) =
    activeCell actors.snitch == activeCell actors.player
-- ~\~ end
-- ~\~ begin <<lit/slasher.md|update>>[3]
updateActor : Grid -> Float -> Actor -> Actor
updateActor grid dt actor =
    let a = activeCell actor
        b = activeCell <| moveActor dt actor 
    in if a /= b then case (gridRef a grid) of
        Slash     -> bounceActor dt Slash actor
        BackSlash -> bounceActor dt BackSlash actor
        Empty     -> if inRange b 
            then moveActor dt actor
            else bounceOffWall dt actor
    else
        moveActor dt actor
-- ~\~ end
-- ~\~ begin <<lit/slasher.md|update>>[4]
activeCell : Actor -> (Int, Int)
activeCell actor =
    let (x, y) = actor.location
    in case (actorDirection actor) of
        East  -> (round x, floor y)
        West  -> (round (x - 1.0), floor y)
        North -> (floor x, round (y - 1.0))
        South -> (floor x, round y)            
-- ~\~ end
-- ~\~ begin <<lit/slasher.md|update>>[5]
type Direction = North | East | South | West

actorDirection : Actor -> Direction
actorDirection actor =
    let (vx, vy) = actor.velocity
    in if (abs vx) > (abs vy) then
        if vx > 0 then East else West
    else
        if vy > 0 then South else North
-- ~\~ end
-- ~\~ begin <<lit/slasher.md|update>>[6]
moveActor : Float -> Actor -> Actor
moveActor dt actor =
    let (x, y)   = actor.location
        (vx, vy) = actor.velocity
    in { actor | location = (x + dt * vx, y + dt * vy) }

bounceActor : Float -> Cell -> Actor -> Actor
bounceActor dt cell actor =
    let (i, j)   = activeCell actor
        (vx, vy) = actor.velocity
        newloc   = ((toFloat i) + 0.5, (toFloat j) + 0.5)
    in case cell of
        Slash     -> moveActor dt { location = newloc, velocity = (-vy, -vx) }
        BackSlash -> moveActor dt { location = newloc, velocity = (vy, vx) }
        Empty     -> actor

bounceOffWall : Float -> Actor -> Actor
bounceOffWall dt actor =
    let (x, y)   = actor.location
        (vx, vy) = actor.velocity
        newloc   = case actorDirection actor of
            North -> (x, 0.0)
            South -> (x, 50.0)
            East  -> (80.0, y)
            West  -> (0.0, y)
    in moveActor dt { location = newloc, velocity = (-vx, -vy) }
-- ~\~ end
-- ~\~ begin <<lit/slasher.md|update>>[7]
checkSnitchTime : Model -> Cmd Msg
checkSnitchTime {snitchTime} =
    let (w, h) = config.gridSize
    in if snitchTime < 0.0 
    then Random.generate
            PlaceSnitch
            (Random.pair (Random.int 0 (w - 1))
                         (Random.int 0 (h - 1)))
    else Cmd.none
-- ~\~ end
-- ~\~ begin <<lit/slasher.md|update>>[8]
placeSnitch : (Int, Int) -> Model -> Model
placeSnitch (x, y) ({actors} as model) = 
    { model
    | snitchTime = config.snitchTime
    , actors = 
        { actors 
        | snitch =
            { location = ((toFloat x) + 0.5, (toFloat y) + 0.5)
            , velocity = (0.0, 0.0) } } }
-- ~\~ end
-- ~\~ begin <<lit/slasher.md|update>>[9]
keyMap : String -> Model -> Model
keyMap k ({state} as model) =
    let slash cell = if state == Running
                     then place cell model
                     else model
    in case k of
        " " -> let newState = case state of
                    Running -> Pause
                    Start   -> Running
                    Pause   -> Running
                    Won     -> Won
               in { model | state = newState }
        "ArrowLeft"  -> slash BackSlash
        "ArrowRight" -> slash Slash
        _            -> model
-- ~\~ end
-- ~\~ begin <<lit/slasher.md|update>>[10]
place : Cell -> Model -> Model
place cell ({actors, grid} as model) =
    let loc = activeCell actors.player
    in { model | grid = gridSet loc cell grid }
-- ~\~ end
-- ~\~ begin <<lit/slasher.md|subscriptions>>[0]
keyDecoder : Decode.Decoder Msg
keyDecoder =
  Decode.map KeyPress (Decode.field "key" Decode.string)

subscriptions : Model -> Sub Msg
subscriptions model = Sub.batch
    [ onAnimationFrameDelta TimeStep
    , onKeyDown keyDecoder
    ]
-- ~\~ end
-- ~\~ begin <<lit/slasher.md|view>>[0]
scale : Int
scale = config.scale

fScale : Float
fScale = toFloat scale

viewCell : (Int, Int) -> Cell -> List (Html Msg)
viewCell (i, j) c =
    case c of
        Slash ->     [ line [ x1 (String.fromInt (scale * i + scale))
                            , y1 (String.fromInt (scale * j))
                            , x2 (String.fromInt (scale * i))
                            , y2 (String.fromInt (scale * j + scale))
                            , class "slash" ] [] ]
        BackSlash -> [ line [ x1 (String.fromInt (scale * i))
                            , y1 (String.fromInt (scale * j))
                            , x2 (String.fromInt (scale * i + scale))
                            , y2 (String.fromInt (scale * j + scale))
                            , class "slash" ] [] ]
        Empty ->     []

formatPath : List (Float, Float) -> String
formatPath pts = case pts of
    []           -> ""
    (x, y)::rest -> (String.fromFloat <| x * fScale) ++ "," ++
                    (String.fromFloat <| y * fScale) ++ " " ++ formatPath rest

viewHero : Actor -> Html Msg
viewHero actor =
    let (x, y) = actor.location
        path   = case actorDirection actor of
            South -> [ (x, y)
                     , (x + 0.3, y - 1)
                     , (x - 0.3, y - 1) ]
            North -> [ (x, y)
                     , (x + 0.3, y + 1)
                     , (x - 0.3, y + 1) ]
            West  -> [ (x, y)
                     , (x + 1, y + 0.3)
                     , (x + 1, y - 0.3) ]
            East  -> [ (x, y)
                     , (x - 1, y + 0.3)
                     , (x - 1, y - 0.3) ]
    in polygon [ points <| formatPath path, class "hero" ] []

viewSnitch : Actor -> Html Msg
viewSnitch actor =
    let (x, y) = actor.location
    in circle [ cx (String.fromFloat <| x * fScale)
              , cy (String.fromFloat <| y * fScale)
              , r (String.fromInt <| scale // 2)
              , class "snitch" ] []

viewOverlay : GameState -> Html Msg
viewOverlay state =
    let (w, h)  = config.gridSize
        sWidth  = (String.fromInt <| config.scale * w)
        sHeight = (String.fromInt <| config.scale * h)
        middleX = (String.fromInt <| config.scale * w // 2)
        middleY = (String.fromInt <| config.scale * h // 2)
        rectA   = rect [ x "0", y "0", width sWidth
                       , height sHeight
                       , rx (String.fromInt <| scale)
                       , ry (String.fromInt <| scale)
                       , style "fill: black" ] []
        textA s = text_ [ x middleX, y middleY, textAnchor "middle" ]
                        [ text s ]
        overlay s = g [ id "overlay" ] [ rectA, textA s ]
    in case state of
        Running -> g [] []
        Won     -> overlay "YOU WIN!"
        Start   -> overlay "press space to start"
        Pause   -> overlay "PAUSE"

viewSnitchBar : Float -> Html Msg
viewSnitchBar t =
    let u       = t / config.snitchTime
        (w, h)  = config.gridSize
        sWidth  = String.fromFloat <| (toFloat w) * u * (toFloat config.scale)
    in rect [ x "0", y (String.fromInt <| h * config.scale + 10)
            , width sWidth, height (String.fromInt <| config.scale // 2)
            , id "snitch-bar" ] []

viewArena : Model -> Html Msg
viewArena ({actors, grid, state, snitchTime} as model) =
    let blurAtPause = class 
                    <| if state == Running
                       then "non-blurred"
                       else "blurred"
    in svg [ width "100%"
           , viewBox ("-3 -3 " ++ (String.fromInt <| scale * 80 + 4) ++ " " ++    (String.fromInt <| scale * 50 + 24))]
           [ g [] [rect [ x "0", y "0"
                        , width (String.fromInt (scale * 80))
                        , height (String.fromInt (scale * 50))
                        , rx (String.fromInt <| scale)
                        , ry (String.fromInt <| scale)
                        , id "box" ] []]
           , g [blurAtPause]
               (concat (toList
               (indexedMap 
                   (\ y rows -> (concat (toList (indexedMap 
                               (\ x cell -> viewCell (x, y) cell)
                               rows))))
                   grid)))
           , g [blurAtPause] [ viewHero actors.player
                  , viewSnitch actors.snitch ]
           , (viewOverlay state)
           , (viewSnitchBar snitchTime)
           ]

view : Model -> Html Msg
view model =
    main_ []
        [ div [ id "header" ] [ text "\\ \\ S L A S H E R / /" ]
        , div [ id "arena" ] [ viewArena model ]
        , div [ id "help" ] [ text "keys: Left \\ | Right / | Space pause" ]
        , div [ id "footer" ]
        [ text "Use the source, at "
        , a [ href "https://entangled.github.io/" ]
            [ text "Entangled!" ] ]
        ]
-- ~\~ end
-- ~\~ end
