module Snake.Control where

import Snake.Config exposing (GameConfig)
import Snake.Model.Snake as Snake
import Snake.Model.Direction exposing (Direction(..))
import Char
import Keyboard
import Signal
import Time exposing (Time)

type Input = Tick | Command Direction | Next | Null
type alias ExternalInput = Int

tickSignal : GameConfig -> Signal Time
tickSignal gameConfig =
    Time.fps gameConfig.fps

-- Bind a key to an input. Fires when the key is pressed.
keySignal : Char.KeyCode -> Input -> Signal Input
keySignal key input =
    Signal.map (\_ -> input)
        (Signal.filter identity False (Keyboard.isDown key))

inputSignal : GameConfig -> Signal ExternalInput -> Signal Input
inputSignal gameConfig extInput =
    Signal.mergeMany
        [ Signal.map (\_ -> Tick) (tickSignal gameConfig)
        , Signal.map inputFromExternal extInput
        , keySignal 32 Next  -- space key
        , keySignal 37 (Command Left)
        , keySignal 38 (Command Up)
        , keySignal 39 (Command Right)
        , keySignal 40 (Command Down)
        ]

inputFromExternal : ExternalInput -> Input
inputFromExternal i =
    case i of
        -1 -> Next
        0 -> Null
        1 -> Command Up
        2 -> Command Right
        3 -> Command Down
        4 -> Command Left
        _ -> Debug.crash "Unknown input"
