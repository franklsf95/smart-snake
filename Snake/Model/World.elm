module Snake.Model.World where

import Snake.Model.Cell exposing (Cell)
import Snake.Model.Size exposing (Size)
import Snake.Model.Snake exposing (Snake)

{- World definition -}

type alias World =
    { size : Size
    , snake : Snake
    , food : Cell
    }
