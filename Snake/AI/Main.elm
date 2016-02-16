module Snake.AI.Main where

import Snake.Model.Snake as Snake exposing (Snake)
import Snake.Model.World as World exposing (World)
import Snake.AI.Interface exposing (AIState)
import Snake.Control as Control

-- the main function that evaluates a world and produces the next step
next : World -> (Control.Input, AIState)
next _ = (Control.Command Snake.Up, 0)
