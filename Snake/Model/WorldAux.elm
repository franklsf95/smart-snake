-- This module is to resolve circular dependency between AI and World
module Snake.Model.WorldAux where

import Snake.Model.Cell exposing (Cell)
import Snake.Model.Snake as Snake
import Snake.Model.World as World exposing (World)
import Snake.Config as Config
import Snake.Control as Control
import Snake.Utility as U
import Random

{- Update World -}

updateWorld : Control.Input -> World -> World
updateWorld input world =
    case input of
        Control.Tick ->
            if Snake.nextBodyCell world.snake == world.food then
                let
                    world' = genFood world
                    scoreAdd = Config.scoreFood + Config.scoreMove
                in
                    { world' | snake = Snake.grow world.snake
                             , commandHandled = False
                             , gameScore = world.gameScore + scoreAdd }
            else
                { world | snake = Snake.move world.snake
                        , commandHandled = False
                        , gameScore = world.gameScore + Config.scoreMove }
        _ ->
            handleCommand input world

handleCommand : Control.Input -> World -> World
handleCommand input world =
    case input of
        Control.Command dir ->
            if world.commandHandled then
                world
            else
                { world | snake = Snake.turn dir world.snake
                        , commandHandled = True } -- to prevent a second turn
        _ ->
            world

isGameOver : World -> Bool
isGameOver world =
    let
        head = U.head world.snake.body
        tail = U.tail world.snake.body
    in
        head.x < 0
            || head.x >= world.size.w
            || head.y < 0
            || head.y >= world.size.h  -- head hits wall
            || cellInCells head tail -- head hits body

cellInCells : Cell -> List Cell -> Bool
cellInCells head tail =
    List.foldr (\c acc -> acc || c == head) False tail

genFood : World -> World
genFood world =
    let
        (food', seed') = Random.generate world.gen world.seed
        world' = { world
                    | food = food'
                    , seed = seed' }
    in
        if cellInCells food' world.snake.body then
            genFood world'
        else
            world'

