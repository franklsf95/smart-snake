module Main where

import Snake.Control
import Snake.Game
import Snake.Visual
import Graphics.Element as E
import Signal
import Window

{- Main -}

main : Signal E.Element
main =
    Signal.map Snake.Visual.view Snake.Game.gameSignal
