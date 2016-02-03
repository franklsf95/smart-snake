module Snake.Model.Snake where

import Snake.Model.Cell exposing (Cell)
import Snake.Model.Size exposing (Size)
import Snake.Config
import Snake.Utility as U

{- Snake -}

type Direction = Up | Down | Left | Right

type alias Snake =
    { length : Int
    , direction : Direction
    , body : List Cell
    }

{- Snake movement -}

-- The snake moves one step forward (default action)
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
        headCell = U.head snake.body
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
turn : Direction -> Snake -> Snake
turn newDirection snake =
    if (newDirection == Up && snake.direction == Down)
        || (newDirection == Down && snake.direction == Up)
        || (newDirection == Left && snake.direction == Right)
        || (newDirection == Right && snake.direction == Left)
        then
            snake  -- reject turning
    else
        { snake | direction = newDirection }

{- Snake constructor -}

-- Initialize the initial snake on the arena
initialSnake : Int -> Size -> Snake
initialSnake len size =
    let
        x0 = size.w // 2
        y0 = size.h // 2
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
