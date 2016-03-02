-- This module is to resolve circular dependency between AI and World
module Snake.Model.WorldAux where

import Snake.Model.Cell exposing (Cell)
import Snake.Model.Snake as Snake
import Snake.Model.World as World exposing (World)
import Snake.Config exposing (GameConfig)
import Snake.Control as Control
import Snake.Utility as U
import Random
import Set exposing (Set)

{- Update World -}

updateWorld : GameConfig -> Control.Input -> World -> World
updateWorld gameConfig input world =
    case input of
        Control.Tick ->
            if Snake.nextBodyCell world.snake == world.food then
                let
                    world' = genFood world
                    scoreAdd = gameConfig.scoreFood + gameConfig.scoreMove
                in
                    { world' | snake = Snake.grow world.snake
                             , commandHandled = False
                             , gameScore = world.gameScore + scoreAdd }
            else
                { world | snake = Snake.move world.snake
                        , commandHandled = False
                        , gameScore = world.gameScore + gameConfig.scoreMove }
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
        -- If head and tail are the same cell, then the bodySet would have
        -- size less than the snake length
        headHitTail = Set.size world.snake.bodySet /= world.snake.length
    in
        cellOutOfBound head world || headHitTail

cellOutOfBound : Cell -> World -> Bool
cellOutOfBound (x, y) world =
    x < 0 || x >= world.size.w || y < 0 || y >= world.size.h

cellInSnakeBody : Cell -> World -> Bool
cellInSnakeBody c world = Set.member c world.snake.bodySet

genFood : World -> World
genFood world =
    let
        (food', seed') = Random.generate world.gen world.seed
        world' = { world
                    | food = food'
                    , seed = seed' }
    in
        if cellInSnakeBody food' world then
            genFood world'
        else
            world'

