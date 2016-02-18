-- AI BrownianMotion
module AI.Main where

import Model.Snake as Snake exposing (Snake, Direction (..))
import Model.World as World exposing (World)
import Model.WorldAux as WorldAux
import AI.Interface exposing (AIState)
import Control as Control exposing (Input (..))
import Utility as U
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
        base = [Null, Null]  -- with higher probability
    in
        if snake.direction == Up || snake.direction == Down then
            List.append base [Command Left, Command Right]
        else
            List.append base [Command Up, Command Down]

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
