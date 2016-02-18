-- AI Greedy
module Snake.AI.Main where

import Snake.Model.Cell exposing (Cell)
import Snake.Model.Snake as Snake exposing (Snake, Direction (..))
import Snake.Model.World as World exposing (World)
import Snake.Model.WorldAux as WorldAux
import Snake.AI.Interface exposing (AIState)
import Snake.Control as Control exposing (Input (..))
import Snake.Utility as U
import Random

-- the main function that evaluates a world and produces the next step
{-
    The basic idea is:
    1. Determine the correct directions to the food
    2. Choose one that is valid and will not result in death
    3. If nothing is chosen, do random walk (that will not result in death)
-}
next : World -> (Input, AIState)
next world =
    let
        snake = world.snake
        cur = snake.direction
        dirs = relativeDirection world.food (U.head world.snake.body)
        willNotDie d = not (willDie (Command d) world)
        findValidTurn ds =
            case ds of
                [] ->
                    Nothing
                d::ds' ->
                    if Snake.isValidTurn d snake && willNotDie d then
                        Just (Command d)
                    else
                        findValidTurn ds'
        cmd =
            if List.member cur dirs && willNotDie cur then
                -- stay on the current direction
                Just Null
            else
                findValidTurn dirs
    in
        case cmd of
            Nothing ->
                nextRandom world
            Just c ->
                (c, world.auxiliaryState)

relativeDirection : Cell -> Cell -> List Direction
relativeDirection food head =
    let
        f x1 x2 y1 y2 =
            if x1 < x2 then
                [y1]
            else if x1 == x2 then
                []
            else
                [y2]
    in
        List.append (f food.x head.x Left Right) (f food.y head.y Down Up)

{- Random Walk -}

nextRandom : World -> (Input, AIState)
nextRandom world =
    let
        commands = possibleCommands world.snake
        auxState = world.auxiliaryState
        (cmd, seed') = nextCommand world auxState.seed commands
        auxState' = { auxState
                    | seed = seed' }
        _ = Debug.log "Random choice" cmd
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
