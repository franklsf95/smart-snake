module Snake.Game where

import Snake.Model.Snake exposing (initialSnake)
import Snake.Model.World exposing (World)

isGameOver : World -> Bool
isGameOver _ = False

initialWorld : World
initialWorld =
    let
        size = { w = 20, h = 10 }
    in
        { size = size
        , snake = initialSnake 6 size
        , food = { x = 3, y = 5 }
        }
