module Snake.Control where

import Snake.Config as Config
import Snake.Model.Snake as Snake
import Snake.Model.Direction exposing (Direction(..))
import Char
import Keyboard
import Signal
import Time exposing (Time)

type Input = Tick | Command Direction | Next | Null

tickSignal : Signal Time
tickSignal = Time.fps Config.fps

-- Bind a key to an input. Fires when the key is pressed.
keySignal : Char.KeyCode -> Input -> Signal Input
keySignal key input =
    Signal.map (\_ -> input)
        (Signal.filter identity False (Keyboard.isDown key))

inputSignal : Signal Input
inputSignal =
    Signal.mergeMany
        [ Signal.map (\_ -> Tick) tickSignal
        , keySignal 32 Next  -- space key
        , keySignal 37 (Command Left)
        , keySignal 38 (Command Up)
        , keySignal 39 (Command Right)
        , keySignal 40 (Command Down)
        ]
