module Snake.Main where

import Snake.Config as Config
import Snake.Game exposing (Game)
import Snake.Visual
import Graphics.Element as E
import Signal
import Window

{- Main -}

gameSignal : Signal Game
gameSignal = Snake.Game.gameSignal gameConfig

main : Signal E.Element
main = Signal.map (Snake.Visual.view visualConfig) gameSignal

{- Input: Game Configuration -}

port gameConfig : Config.GameConfig
port visualConfig : Config.VisualConfig

{- Output: Game Info -}

port info : Signal Snake.Visual.GameInfo
port info = Signal.map Snake.Visual.outputInfo gameSignal
