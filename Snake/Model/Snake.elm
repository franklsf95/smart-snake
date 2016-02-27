module Snake.Model.Snake where

import Snake.Model.Cell exposing (Cell)
import Snake.Model.Size exposing (Size)
import Snake.Model.Direction exposing (Direction(..))
import Snake.Config
import Snake.Utility as U
import Set exposing (Set)

{- Snake -}


type alias Snake =
    { length : Int
    , direction : Direction
    , body : List Cell
    , bodySet : Set Cell
    }

{- Snake movement -}

-- The snake moves one step forward (default action)
move : Snake -> Snake
move snake =
    let
        body1 = List.take (snake.length - 1) snake.body
        body2 = (nextBodyCell snake) :: body1
    in
        { snake
            | body = body2
            , bodySet = Set.fromList body2
        }

-- Helper function to generate the next cell for the snake
nextBodyCell : Snake -> Cell
nextBodyCell snake =
    let
        (hx, hy) = U.head snake.body
    in
        case snake.direction of
            Up ->    (hx, hy + 1)
            Down ->  (hx, hy - 1)
            Left ->  (hx - 1, hy)
            Right -> (hx + 1, hy)

-- The snake grows forward when eating food
grow : Snake -> Snake
grow snake =
    let
        body1 = snake.body
        body2 = (nextBodyCell snake) :: body1
    in
        { snake
            | length = snake.length + 1
            , body = body2
            , bodySet = Set.fromList body2
        }

-- Change direction of the snake
turn : Direction -> Snake -> Snake
turn newDirection snake =
    if isValidTurn newDirection snake then
        { snake | direction = newDirection }
    else
        snake  -- reject turning

isValidTurn : Direction -> Snake -> Bool
isValidTurn newDirection snake =
    (newDirection == Up && snake.direction /= Down)
        || (newDirection == Down && snake.direction /= Up)
        || (newDirection == Left && snake.direction /= Right)
        || (newDirection == Right && snake.direction /= Left)

{- Snake constructor -}

-- Initialize the initial snake on the arena
initialSnake : Int -> Size -> Snake
initialSnake len size =
    let
        x0 = size.w // 4
        y0 = size.h // 2
        body = initialBody len (x0, y0) []
    in
        { length = len
        , direction = Right
        , body = body
        , bodySet = Set.fromList body
        }

-- Helper function to generate snake body
initialBody : Int -> (Int, Int) -> List Cell -> List Cell
initialBody len (x, y) acc =
    if len == 0 then
        acc
    else
        let
            newCell = (x, y)
        in
            initialBody (len - 1) (x + 1, y) (newCell :: acc)
