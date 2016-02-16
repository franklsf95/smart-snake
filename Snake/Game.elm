module Snake.Game where

import Snake.Model.Cell exposing (Cell)
import Snake.Model.Snake as Snake
import Snake.Model.World as World exposing (World)
import Snake.AI.Main as AIMain
import Snake.Config as Config
import Snake.Control as Control
import Snake.Utility as U
import Char
import Random
import Signal

{- Game -}

type GameState = Home | Playing | Dead

type alias Game =
    { world : World
    , state : GameState
    }

initialGame : Game
initialGame =
    { world = World.initialWorld
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
            { world = World.initialWorld, state = Playing }
        (Control.Next, Dead) ->
            { game | state = Home }
        _ ->
            game


gameSignal : Signal Game
gameSignal = Signal.foldp updateGame initialGame Control.inputSignal

{- Update World -}

updateWorld : Control.Input -> World -> World
updateWorld input world =
    case input of
        Control.Tick ->
            let
                world =
                    if Config.enableAI then
                        let
                            (input, state') = AIMain.next world
                            _ = Debug.log "AI" input
                            world' = { world | auxiliaryState = state' }
                        in
                            handleCommand input world'
                    else
                        world
            in
                if Snake.nextBodyCell world.snake == world.food then
                    let
                        (food', seed') = Random.generate world.gen world.seed
                    in
                        { world | snake = Snake.grow world.snake
                                , food = food'
                                , seed = seed'
                                , commandHandled = False }
            else
                { world | snake = Snake.move world.snake
                        , commandHandled = False }
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
            || headHitTail head tail -- head hits body

headHitTail : Cell -> List Cell -> Bool
headHitTail head tail =
    List.foldr (\c acc -> acc || c == head) False tail
