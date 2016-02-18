module Snake.Game where

import Snake.Model.World as World exposing (World)
import Snake.Model.WorldAux as WorldAux
import Snake.AI.Main as AIMain
import Snake.Config as Config
import Snake.Control as Control
import Signal

{- Game -}

type GameState = Start | Playing | Dead

type alias Game =
    { world : World
    , state : GameState
    }

initialGame : Game
initialGame =
    { world = World.initialWorld
    , state = Start
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
        (Control.Next, Start) ->
            { world = World.initialWorld, state = Playing }
        (Control.Next, Dead) ->
            { game | state = Start }
        _ ->
            game

runAI : World -> World
runAI world =
    if Config.enableAI then
        let
            (input, state') = AIMain.next world
            _ = if input /= Control.Null then Debug.log "AI" input else input
            world' = { world | auxiliaryState = state' }
        in
            WorldAux.handleCommand input world'
    else
        world

{- Output Game Signal -}

gameSignal : Signal Game
gameSignal = Signal.foldp updateGame initialGame Control.inputSignal
