module Snake.Game where

import Snake.Model.World as World exposing (World)
import Snake.Control as Control
import Char
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
                newWorld = World.updateWorld input game.world
                gameOver = World.isGameOver newWorld
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

