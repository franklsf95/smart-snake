module Snake.Model.Food where

import Snake.Model.Cell exposing (Cell)
import Random

randGen : Int -> Int -> Random.Generator Cell
randGen w h =
    Random.map2
        (\x y -> { x = x, y = y })
        (Random.int 0 (w - 1))
        (Random.int 0 (h - 1))
