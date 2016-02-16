module Snake.Main where

import Snake.Control
import Snake.Game
import Snake.Visual
import Graphics.Element as E
import Signal
import Window

{- Main -}

main : Signal E.Element
main = Signal.map Snake.Visual.mainView Snake.Game.gameSignal

port message : Signal String
port message = Signal.map Snake.Visual.outputMessage Snake.Game.gameSignal

--
