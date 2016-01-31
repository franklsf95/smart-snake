module Main where

import Snake.Model
import Graphics.Element as E exposing (Element)
import Signal

s = Snake.Model.initialSnake 4 (10, 10)

{- Main -}

main : Signal Element
main = Signal.constant (E.show s)
