module Snake.Game where

import Snake.Model.Snake exposing (initialSnake)
import Snake.Model.World exposing (World)

isGameOver : World -> Bool
isGameOver _ = False

initialWorld : World
initialWorld =
    let
        size = { w = 30, h = 20 }
    in
        { size = size
        , snake = initialSnake 4 size
        , food = { x = 0, y = 0 }
        }
