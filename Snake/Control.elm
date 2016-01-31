module Snake.Control where

import Signal
import Time exposing (Time)

type Input = Tick | Command Action

type Action = TurnLeft | TurnRight


tickSignal : Signal Time
tickSignal = Time.fps 5

inputSignal : Signal Input
inputSignal = tickSignal |> Signal.map (\_ -> Tick)
