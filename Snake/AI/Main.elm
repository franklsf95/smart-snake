-- AI Drunk
module Snake.AI.Main where

import Snake.Model.Snake as Snake exposing (Snake)
import Snake.Model.World as World exposing (World)
import Snake.Model.WorldAux as WorldAux
import Snake.AI.Interface exposing (AIState)
import Snake.Control as Control
import Random

-- the main function that evaluates a world and produces the next step
next : World -> (Control.Input, AIState)
next world =
    let
        vert = world.snake.direction == Snake.Up
                || world.snake.direction == Snake.Down
        gen = moveGen vert
        auxState = world.auxiliaryState
        (cmd, seed') = Random.generate gen auxState.seed
        auxState' = { auxState
                    | seed = seed' }
    in
        (cmd, auxState')

-- generates a move that will not result in death
--nextStep :

-- randomly generates the next move
moveGen : Bool -> Random.Generator Control.Input
moveGen vert =
    let
        pNothing = 0.5
        p = (1 - pNothing) / 2
        move1 = if vert then Snake.Left else Snake.Up
        move2 = if vert then Snake.Right else Snake.Down
        f x =
            if x <= pNothing then
                Control.Nothing
            else if x <= pNothing + p then
                Control.Command move1
            else
                Control.Command move2
    in
        Random.map f (Random.float 0 1)

-- check if the snake will die if it makes a move
willDie input world =
    let
        world' = WorldAux.updateWorld input world
        gameOver = WorldAux.isGameOver world'
    in
        gameOver
