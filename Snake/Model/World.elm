module Snake.Model.World where

import Snake.Model.Cell exposing (Cell)
import Snake.Model.Food as Food
import Snake.Model.Size exposing (Size)
import Snake.Model.Snake as Snake exposing (Snake)
import Snake.AI.Interface as AI
import Snake.Config exposing (GameConfig)
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
    , gameScore : Int
    }

{- World -}

initialWorld : GameConfig -> World
initialWorld gameConfig =
    let
        size = { w = gameConfig.arenaWidth, h = gameConfig.arenaHeight }
        seed = Random.initialSeed gameConfig.randomSeed
        gen = Food.randGen size.w size.h
        (food', seed') = Random.generate gen seed
    in
        { size = size
        , snake = Snake.initialSnake gameConfig.snakeInitialLength size
        , food = food'
        , seed = seed'
        , gen = gen
        , commandHandled = False
        , auxiliaryState = AI.initialAuxilaryState
        , gameScore = gameConfig.scoreInitial
        }
