module Model where

import Config
import Util

{--- Snake ---}

type Direction = Up | Down | Left | Right

type alias Cell =
    { x : Int
    , y : Int
    }

type alias Snake =
    { length : Int
    , direction : Direction
    , body : List Cell
    }

{--- Snake movement ---}

-- The snake moves forward (default action)
move : Snake -> Snake
move snake =
    let
        body1 = List.take (snake.length - 1) snake.body
        body2 = (nextBodyCell snake) :: body1
    in
        { snake | body = body2 }

-- Helper function to generate the next cell for the snake
nextBodyCell : Snake -> Cell
nextBodyCell snake =
    let
        headCell = Util.head snake.body
    in
        case snake.direction of
            Up -> { headCell | y = headCell.y + 1 }
            Down -> { headCell | y = headCell.y - 1 }
            Left -> { headCell | x = headCell.x - 1 }
            Right -> { headCell | x = headCell.x + 1 }

-- The snake grows forward when eating food
grow : Snake -> Snake
grow snake =
    let
        body1 = snake.body
        body2 = (nextBodyCell snake) :: body1
    in
        { snake
            | length = snake.length + 1
            , body = body2 }

-- Change direction of the snake
turnLeft : Snake -> Snake
turnLeft snake =
    let
        newDirection = case snake.direction of
            Up -> Left
            Down -> Right
            Left -> Down
            Right -> Up
    in
        { snake | direction = newDirection }

-- Change direction of the snake
turnRight : Snake -> Snake
turnRight snake =
    let
        newDirection = case snake.direction of
            Up -> Right
            Down -> Left
            Left -> Up
            Right -> Down
    in
        { snake | direction = newDirection }

{--- Snake constructor ----}

-- Initialize the initial snake on the arena
initialSnake : Int -> (Int, Int) -> Snake
initialSnake len (w, h) =
    let
        x0 = w // 2
        y0 = h // 2
    in
        { length = len
        , direction = Right
        , body = initialBody len (x0, y0) []
        }

-- Helper function to generate snake body
initialBody : Int -> (Int, Int) -> List Cell -> List Cell
initialBody len (x, y) acc =
    if len == 0 then
        acc
    else
        let
            newCell = { x = x, y = y }
        in
            initialBody (len - 1) (x + 1, y) (newCell :: acc)



{---- Arena ----}

type alias Size = (Int, Int)


{---- Game ----}

--isGameOver : Snake -> Arena -> Bool


