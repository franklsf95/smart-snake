module Snake.Game where

import Snake.Model.Snake as Snake
import Snake.Model.World exposing (World)
import Snake.Control as Control
import Snake.Utility as U
import Char
import Signal

{- World -}

initialWorld : World
initialWorld =
    let
        size = { w = 30, h = 20 }
    in
        { size = size
        , snake = Snake.initialSnake 6 size
        , food = { x = 3, y = 5 }
        }

updateWorld : Control.Input -> World -> World
updateWorld input world =
    case input of
        Control.Tick ->
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


{- Game -}

type GameState = Home | Playing | Dead

type alias Game =
    { world : World
    , state : GameState
    }

initialGame : Game
initialGame =
    { world = initialWorld
    , state = Home
    }

updateGame : Control.Input -> Game -> Game
updateGame input game =
    case (input, game.state) of
        (_, Playing) ->
            let
                newWorld = updateWorld input game.world
                gameOver = isGameOver newWorld
                newState = if gameOver then Dead else Playing
            in
                { world = newWorld
                , state = newState
                }
        (Control.Next, Home) ->
            { world = initialWorld, state = Playing }
        (Control.Next, Dead) ->
            { game | state = Home }
        _ ->
            game


gameSignal : Signal Game
gameSignal = Signal.foldp updateGame initialGame Control.inputSignal

