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
    , aiMessage : String
    }

initialGame : Game
initialGame =
    { world = World.initialWorld
    , state = Start
    , aiMessage = ""
    }

updateGame : Control.Input -> Game -> Game
updateGame input game =
    case (input, game.state) of
        (_, Playing) ->
            let
                (world', aiMessage) = runAI game.world
                world'' = WorldAux.updateWorld input world'
                gameOver = WorldAux.isGameOver world''
                state' = if gameOver then Dead else Playing
            in
                { world = world''
                , state = state'
                , aiMessage = aiMessage
                }
        (Control.Next, Start) ->
            { game
                | world = World.initialWorld
                , state = Playing
            }
        (Control.Next, Dead) ->
            { game | state = Start }
        _ ->
            game

runAI : World -> (World, String)
runAI world =
    if Config.enableAI then
        let
            (input, state') = AIMain.next world
            message = if input /= Control.Null then toString input else ""
            world' = { world | auxiliaryState = state' }
        in
            (WorldAux.handleCommand input world', message)
    else
        (world, "")

{- Output Game Signal -}

gameSignal : Signal Game
gameSignal = Signal.foldp updateGame initialGame Control.inputSignal
