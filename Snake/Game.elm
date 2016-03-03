module Snake.Game where

import Snake.Model.World as World exposing (World)
import Snake.Model.WorldAux as WorldAux
import Snake.AI.Main as AIMain
import Snake.Config exposing (GameConfig)
import Snake.Control as Control exposing (ExternalInput)
import Snake.Utility as U
import Signal

{- Game -}

type GameState = Start | Playing | Dead

type alias Game =
    { world : World
    , state : GameState
    , aiMessage : String
    , lastMessage : String
    , config : GameConfig
    }

initialGame : GameConfig -> Game
initialGame config =
    { world = World.initialWorld config
    , state = Start
    , aiMessage = ""
    , lastMessage = ""
    , config = config
    }

updateGame : Control.Input -> Game -> Game
updateGame input game =
    case (input, game.state) of
        (_, Playing) ->
            let
                lastMessage = game.aiMessage
                (world', msg) = runAI game.config game.world
                message' = if msg == "" then lastMessage else msg
                world'' = WorldAux.updateWorld game.config input world'
                gameOver = WorldAux.isGameOver world''
                state' = if gameOver then Dead else Playing
            in
                { game
                    | world = world''
                    , state = state'
                    , aiMessage = message'
                    , lastMessage = lastMessage
                }
        (Control.Next, Start) ->
            { game
                | world = World.initialWorld game.config
                , state = Playing
            }
        (Control.Next, Dead) ->
            { game | state = Start }
        _ ->
            game

runAI : GameConfig -> World -> (World, String)
runAI gameConfig world =
    if gameConfig.enableAI then
        let
            (input, state') = AIMain.next world
            m = if state'.lastStepRandom then " (Random)   " else "   "
            lastTurn = toString world.auxiliaryState.lastTurn
            message =
                if input /= Control.Null then
                    toString input ++ m ++ lastTurn
                else
                    ""
            world' = { world | auxiliaryState = state' }
        in
            (WorldAux.handleCommand input world', message)
    else
        (world, "")

{- Output Game Signal -}

gameSignal : GameConfig -> Signal ExternalInput -> Signal Game
gameSignal config extInput =
    Signal.foldp updateGame (initialGame config)
                            (Control.inputSignal config extInput)
