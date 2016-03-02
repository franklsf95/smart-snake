module Snake.Visual where

import Snake.Model.Cell exposing (Cell)
import Snake.Model.Snake exposing (Snake)
import Snake.Model.World exposing (World)
import Snake.Game as Game exposing (Game)
import Snake.Config exposing (VisualConfig)
import Snake.Utility as U
import Array exposing (Array)
import Color exposing (Color)
import Graphics.Collage as C
import Graphics.Element as E exposing (Element)
import Set

{- Individual Elements -}

type ElementMark = Empty | Food | Snake Int

{- Generating World Grid -}

type alias MarkGrid = Array (Array ElementMark)

worldToMarkGrid : World -> MarkGrid
worldToMarkGrid world =
    let
        w = world.size.w
        h = world.size.h
        array = Array.repeat h (Array.repeat w Empty)
    in
        array
            |> markFood world.food
            |> markSnake world.snake

markFood : Cell -> MarkGrid -> MarkGrid
markFood (x, y) array =
    U.set y x Food array

markSnake : Snake -> MarkGrid -> MarkGrid
markSnake snake array =
    markSnakeHelper snake.body 0 array

markSnakeHelper : List Cell -> Int -> MarkGrid -> MarkGrid
markSnakeHelper cs i acc =
    case cs of
        [] -> acc
        (x, y)::cs' -> markSnakeHelper cs' (i + 1) (U.set y x (Snake i) acc)

{- Draw Grid Elements -}

type alias ElementGrid = Array (Array Element)

worldToElementGrid : VisualConfig -> World -> ElementGrid
worldToElementGrid config world =
    world |> worldToMarkGrid |> Array.map (Array.map (drawElement config))

drawElement : VisualConfig -> ElementMark -> Element
drawElement config mark =
    let
        side = config.cellSize
        sq = C.square (toFloat side)
        darken i = (sqrt (toFloat i)) / 8
        bodyColor = colorFromRGB config.colorBody
        form = case mark of
            Empty ->
                sq |> C.filled (colorFromRGB config.colorBackground)
            Food ->
                sq |> C.filled (colorFromRGB config.colorFood)
            Snake i ->
                sq |> C.filled (darkenColor (darken i) bodyColor)
    in
        C.collage side side [form]

colorFromRGB : (Int, Int, Int) -> Color
colorFromRGB (r, g, b) = Color.rgb r g b

darkenColor : Float -> Color -> Color
darkenColor p color =
    let
        c = Color.toRgb color
        f x = round (toFloat x * (1 - p))
    in
        Color.rgb (f c.red) (f c.green) (f c.blue)

{- Compose Grid Elements -}

worldToCompositeElement : VisualConfig -> World -> Element
worldToCompositeElement config world =
    let
        array = worldToElementGrid config world
        loopRow : Int -> Element -> Element
        loopRow i acc =
            if i == world.size.h then
                acc
            else
                let
                    rowArray = Array.get i array |> U.unmaybe "no such row"
                    newRow = (E.flow E.right (Array.toList rowArray))
                in
                    loopRow (i + 1) (E.below acc newRow)
    in
        loopRow 0 E.empty

{- Game Canvas -}

drawWorld : VisualConfig -> World -> Element
drawWorld config world =
    let
        worldElement = worldToCompositeElement config world
    in
        worldElement
        --E.flow E.down [worldElement, E.show world.gameScore, E.show world.snake.length, E.show world.food]

{- Main view function -}

view : VisualConfig -> Game -> Element
view config game = drawWorld config game.world

{- Output game info -}

type alias GameInfo =
    { state : String
    , snakeLength : Int
    , score : Int
    , aiMessage : String
    }

outputInfo : Game -> GameInfo
outputInfo game =
    let
        snakeLength = game.world.snake.length
    in
        { state = toString game.state
        , snakeLength = snakeLength
        , score = game.world.gameScore
        , aiMessage = game.aiMessage
        }
