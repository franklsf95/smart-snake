module Snake.Control where

import Snake.Model.Snake as Snake
import Char
import Keyboard
import Signal
import Time exposing (Time)

type Input = Tick | Command Snake.Direction | Next | Nothing

tickSignal : Signal Time
tickSignal = Time.fps 5

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
        , keySignal 37 (Command Snake.Left)
        , keySignal 38 (Command Snake.Up)
        , keySignal 39 (Command Snake.Right)
        , keySignal 40 (Command Snake.Down)
        ]
