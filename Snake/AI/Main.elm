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
import Set exposing (Set)

-- the main function that evaluates a world and produces the next step
{-
    The basic idea is:
    1. Determine the correct directions to the food
    2. Choose one that is valid and will not result in death
    3. If nothing is chosen, do random walk, which
      a) will not result in immediate death
      b) look ahead to avoid a dead end
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
        auxState = world.auxiliaryState
        stateReset = { auxState | lastStepRandom = False }
    in
        case cmd of
            Nothing ->
                nextRandom world
            Just c ->
                (c, stateReset)

relativeDirection : Cell -> Cell -> List Direction
relativeDirection food head =
    let
        (fx, fy) = food
        (hx, hy) = head
        f x1 x2 y1 y2 =
            if x1 < x2 then
                [y1]
            else if x1 == x2 then
                []
            else
                [y2]
    in
        List.append (f fx hx Left Right) (f fy hy Down Up)

{- Random Walk -}

nextRandom : World -> (Input, AIState)
nextRandom world =
    let
        commands = possibleCommands world.snake
        auxState = world.auxiliaryState
        (cmd, seed') = nextCommand world auxState.seed commands
        auxState' = { auxState
                    | seed = seed'
                    , lastStepRandom = True
                    }
    in
        (cmd, auxState')

-- generates a list of all legal moves
possibleCommands : Snake -> List Input
possibleCommands snake =
    let
        base = [Null, Null]  -- Null 0.5, Left 0.25, Right 0.25
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
willDie : Input -> World -> Bool
willDie input world =
    let
        world' = WorldAux.updateWorld input world
        world'' = WorldAux.updateWorld Tick world'
        gameOver = WorldAux.isGameOver world''
    in
        if gameOver then
            True
        else
            case input of
                Command d ->
                    isDeadEnd d world
                _ ->
                    False

-- check if one side of the head is a dead end (confined by own body)
-- try filling the empty space, if less than 1/4 total area then it is dead end
isDeadEnd : Direction -> World -> Bool
isDeadEnd d world =
    let
        maxSteps = world.size.w * world.size.h // 4
        start = world.snake |> Snake.turn d |> Snake.nextBodyCell
        filledRegion = fill world maxSteps [start] Set.empty
        filledArea = Set.size filledRegion
        isDeadEnd = filledArea < maxSteps
        _ =
            if isDeadEnd then Debug.log "I foresee death" (filledArea, d)
            else (0, Left)
    in
        isDeadEnd

fill : World -> Int -> List Cell -> Set Cell -> Set Cell
fill world maxSteps queue visited =
    case queue of
        [] ->
            visited
        c::cs ->
            if Set.size visited >= maxSteps then
                visited
            else
                let
                    visited' = Set.insert c visited
                    checkAndAdd cell q =
                        if Set.member cell visited then
                            q -- |> Debug.log "NO - visited"
                        else if WorldAux.cellOutOfBound cell world then
                            q -- |> Debug.log "NO - hit wall"
                        else if WorldAux.cellInCells cell world.snake.body then
                            q -- |> Debug.log "NO - hit body"
                        else
                            cell :: q -- |> Debug.log "YES"
                    (x, y) = c
                    q1 = checkAndAdd (x + 1, y) cs
                    q2 = checkAndAdd (x - 1, y) q1
                    q3 = checkAndAdd (x, y + 1) q2
                    q4 = checkAndAdd (x, y - 1) q3
                in
                    fill world maxSteps q4 visited'

