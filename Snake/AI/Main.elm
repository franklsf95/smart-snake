-- AI BrownianMotion
module Snake.AI.Main where

import Snake.Model.Snake as Snake exposing (Snake)
import Snake.Model.World as World exposing (World)
import Snake.Model.WorldAux as WorldAux
import Snake.AI.Interface exposing (AIState)
import Snake.Control as Control exposing (Input (..))
import Snake.Utility as U
import Random

-- the main function that evaluates a world and produces the next step
next : World -> (Input, AIState)
next world =
    let
        commands = possibleCommands world.snake
        auxState = world.auxiliaryState
        (cmd, seed') = nextCommand world auxState.seed commands
        auxState' = { auxState
                    | seed = seed' }
    in
        (cmd, auxState')

-- generates a list of all legal moves
possibleCommands : Snake -> List Input
possibleCommands snake =
    let
        base = [Control.Nothing, Control.Nothing]  -- with higher probability
    in
        if snake.direction == Snake.Up || snake.direction == Snake.Down then
            List.append base [Command Snake.Left, Command Snake.Right]
        else
            List.append base [Command Snake.Up, Command Snake.Down]

-- generates a move that will not result in death
nextCommand : World -> Random.Seed -> List Input -> (Input, Random.Seed)
nextCommand world seed commands =
    case commands of
        [] ->
            Debug.crash "no possible command"
        [c] ->
            (c, seed)
        _ ->
            let
                n = List.length commands
                (i, seed') = Random.generate (Random.int 0 (n - 1)) seed
                (cmd, rest) = U.nthAndRest i commands
            in
                -- choose a different command
                if willDie cmd world then
                    nextCommand world seed' rest
                else
                    (cmd, seed')

-- check if the snake will die if it makes a move
willDie input world =
    let
        world' = WorldAux.updateWorld input world
        world'' = WorldAux.updateWorld Tick world'
        gameOver = WorldAux.isGameOver world''
    in
        gameOver
