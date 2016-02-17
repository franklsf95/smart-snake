module Snake.Game where

import Snake.Model.World as World exposing (World)
import Snake.Model.WorldAux as WorldAux
import Snake.AI.Main as AIMain
import Snake.Config as Config
import Snake.Control as Control
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
                world = runAI game.world
                world' = WorldAux.updateWorld input world
                gameOver = WorldAux.isGameOver world'
                state' = if gameOver then Dead else Playing
            in
                { world = world'
                , state = state'
                }
        (Control.Next, Home) ->
            { world = World.initialWorld, state = Playing }
        (Control.Next, Dead) ->
            { game | state = Home }
        _ ->
            game

runAI : World -> World
runAI world =
    if Config.enableAI then
        let
            (input, state') = AIMain.next world
            _ = Debug.log "AI" input
            world' = { world | auxiliaryState = state' }
        in
            WorldAux.handleCommand input world'
    else
        world

{- Output Game Signal -}

gameSignal : Signal Game
gameSignal = Signal.foldp updateGame initialGame Control.inputSignal
