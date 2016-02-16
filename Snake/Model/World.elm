module Snake.Model.World where

import Snake.Model.Cell exposing (Cell)
import Snake.Model.Food as Food
import Snake.Model.Size exposing (Size)
import Snake.Model.Snake as Snake exposing (Snake)
import Snake.AI.Interface as AI
import Snake.Config as Config
import Snake.Control as Control
import Random

{- World definition -}

type alias World =
    { size : Size
    , snake : Snake
    , food : Cell
    , seed : Random.Seed
    , gen : Random.Generator Cell
    , commandHandled : Bool -- to prevent duplicate commands within one tick
    , auxiliaryState : AI.AIState -- auxiliary state
    }


{- World -}

initialWorld : World
initialWorld =
    let
        size = { w = Config.arenaWidth, h = Config.arenaHeight }
        seed = Random.initialSeed 42
        gen = Food.randGen size.w size.h
        (food', seed') = Random.generate gen seed
    in
        { size = size
        , snake = Snake.initialSnake Config.initialLength size
        , food = food'
        , seed = seed'
        , gen = gen
        , commandHandled = False
        , auxiliaryState = AI.initialAuxilaryState
        }
