module Snake.Visual where

import Snake.Model.Cell exposing (Cell)
import Snake.Model.Snake exposing (Snake)
import Snake.Model.World exposing (World)
import Snake.Utility as U
import Array exposing (Array)
import Color
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
markFood food array =
    U.set food.y food.x Food array

markSnake : Snake -> MarkGrid -> MarkGrid
markSnake snake array =
    markSnakeHelper snake.body 0 array

markSnakeHelper : List Cell -> Int -> MarkGrid -> MarkGrid
markSnakeHelper cs i acc =
    case cs of
        [] -> acc
        c::cs' -> markSnakeHelper cs' (i + 1) (U.set c.y c.x (Snake i) acc)

{- Draw Grid Elements -}

resizeFactor = 20

type alias ElementGrid = Array (Array Element)

worldToElementGrid : World -> ElementGrid
worldToElementGrid =
    worldToMarkGrid >> Array.map (Array.map drawElement)

drawElement : ElementMark -> Element
drawElement mark =
    let
        side = resizeFactor
        sq = C.square side
        form = case mark of
            Empty ->
                sq |> C.filled Color.black
            Food ->
                sq |> C.filled Color.white
            Snake i ->
                sq |> C.filled Color.yellow
                   |> C.alpha (toFloat i / 10 + 0.2)
    in
        C.collage side side [form]

{- Compose Grid Elements -}

worldToCompositeElement : World -> Element
worldToCompositeElement world =
    let
        array = worldToElementGrid world
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

{- Main function -}

view : World -> Element
view world = worldToCompositeElement world
