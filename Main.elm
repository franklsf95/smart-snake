module Main where

import Snake.Game as Game
import Snake.Visual as Visual
import Graphics.Element as E
import Signal
import Window

{- Main -}

main : Signal E.Element
main = Signal.constant (Visual.view Game.initialWorld)
