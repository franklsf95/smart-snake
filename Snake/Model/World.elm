module Snake.Model.World where

import Snake.Model.Cell exposing (Cell)
import Snake.Model.Food as Food
import Snake.Model.Size exposing (Size)
import Snake.Model.Snake as Snake exposing (Snake)
import Snake.Control as Control
import Snake.Utility as U
import Random

{- World definition -}

type alias World =
    { size : Size
    , snake : Snake
    , food : Cell
    , seed : Random.Seed
    , gen : Random.Generator Cell
    }


{- World -}

initialWorld : World
initialWorld =
    let
        size = { w = 30, h = 20 }
        seed = Random.initialSeed 42
        gen = Food.randGen size.w size.h
        newFoodSeed = Random.generate gen seed
    in
        { size = size
        , snake = Snake.initialSnake 6 size
        , food = fst newFoodSeed
        , seed = snd newFoodSeed
        , gen = gen
        }

updateWorld : Control.Input -> World -> World
updateWorld input world =
    case input of
        Control.Tick ->
            if Snake.nextBodyCell world.snake == world.food then
                let
                    newFoodSeed = Random.generate world.gen world.seed
                in
                    { world | snake = Snake.grow world.snake
                            , food = fst newFoodSeed
                            , seed = snd newFoodSeed }
            else
                { world | snake = Snake.move world.snake }
        Control.Command dir ->
            { world | snake = Snake.turn dir world.snake }
        _ ->
            world

isGameOver : World -> Bool
isGameOver world =
    let
        head = U.head world.snake.body
    in
        head.x < 0 || head.x >= world.size.w
            || head.y < 0 || head.y >= world.size.h

