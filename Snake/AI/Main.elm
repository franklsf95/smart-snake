-- AI Smart
module Snake.AI.Main where

import Snake.Model.Cell exposing (Cell)
import Snake.Model.Snake as Snake exposing (Snake)
import Snake.Model.World as World exposing (World)
import Snake.Model.Direction as Direction exposing (Direction(..))
import Snake.Model.WorldAux as WorldAux
import Snake.AI.Interface exposing (AIState)
import Snake.Config as Config
import Snake.Control as Control exposing (Input (..))
import Snake.Utility as U
import Random
import Set exposing (Set)


-- the main function that evaluates a world and produces the next step
{-
    The basic idea is:
    1. Determine the correct directions to the food
    2. Choose one that is valid and will not result in death
    3. If nothing is chosen, then walk in original direction
    4. If must turn, then evaluate the map and choose a direction with
       more free space
-}
next : World -> (Input, AIState)
next world =
    let
        snake = world.snake
        cur = snake.direction
        dirs = relativeDirection world.food (U.head world.snake.body)
        dangerousMove d =
            if willDie world (Command d) then
                True
            else
                deadEndScore world d |> snd
        safeMove = not << dangerousMove
        findValidTurn ds =
            case ds of
                [] ->
                    Nothing
                d::ds' ->
                    if Snake.isValidTurn d snake && safeMove d then
                        Just (Command d)
                    else
                        findValidTurn ds'
        cmd =
            if List.member cur dirs && safeMove cur then
                -- stay on the current direction
                Just Null
            else
                findValidTurn (dirs ++ [world.auxiliaryState.lastTurn])
        auxState = world.auxiliaryState
        stateReset = { auxState | lastStepRandom = False }
    in
        case cmd of
            Nothing ->
                -- If walking straight will not cause death, then walk straight
                -- Else make a random turn
                if not (willDie world Null) then
                    (Null, stateReset)
                else
                    nextRandom world
            Just (Command d) ->
                ((Command d), { stateReset | lastTurn = cur })
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

-- Score measures the potential danger of a step
-- A larger score means farther from death. 0 means immediate death
type alias Score = Int

-- scoreSafe indicates no foreseeable danger
scoreSafe : Score
scoreSafe = 999999999

nextRandom : World -> (Input, AIState)
nextRandom world =
    let
        commands = possibleCommands world.snake
        safeCommands = filterCommands world commands
        auxState = world.auxiliaryState
        (cmd, seed') = nextCommand auxState.seed safeCommands
        auxState' = { auxState
                    | seed = seed'
                    , lastStepRandom = True
                    , lastTurn =
                        case cmd of
                            Command d ->
                                world.snake.direction
                            _ ->
                                world.auxiliaryState.lastTurn
                    }
    in
        (cmd, auxState')

-- generates a list of all legal moves
possibleCommands : Snake -> List Input
possibleCommands snake =
    let
        base = []
    in
        if snake.direction == Up || snake.direction == Down then
            List.append base [Command Left, Command Right]
        else
            List.append base [Command Up, Command Down]

-- only chooses the "safe" commands, or the best among the dangerous ones
-- If a safe choice exists, then only choose from safe choices;
-- Otherwise, choose the least dangerous one.
filterCommands : World -> List Input -> List Input
filterCommands world commands =
    let
        scores = List.map (evaluateCommand world) commands
        pairs = List.map2 (,) scores commands |> Debug.log "scores"
        comparePair (s1, _) (s2, _) = s1 > s2
        (maxScore, maxCmd) = U.maxBy comparePair pairs |> U.unmaybe "score"
        filtered = List.filter (\(s, _) -> s == maxScore) pairs
        filteredResult = List.map snd filtered
    in
        filteredResult

-- generates a move that will not result in death
nextCommand : Random.Seed -> List Input -> (Input, Random.Seed)
nextCommand seed commands =
    case commands of
        [] ->
            Debug.crash "no possible command"
        [c] ->
            (c, seed)
        _ ->
            let
                n = List.length commands
                (i, seed') = Random.generate (Random.int 0 (n - 1)) seed
                (cmd, _) = U.nthAndRest i commands
            in
                (cmd, seed')

evaluateCommand : World -> Input -> Score
evaluateCommand world input =
    if willDie world input then
        0
    else
        case input of
            Command d ->
                deadEndScore world d |> fst
            _ ->
                scoreSafe

-- check if the snake will die if it makes a move
willDie : World -> Input -> Bool
willDie world input =
    let
        update = WorldAux.updateWorld Config.defaultGameConfig
        world' = update input world
        world'' = update Tick world'
        gameOver = WorldAux.isGameOver world''
    in
        gameOver

-- check if one side of the head is a dead end (confined by own body)
-- try filling the empty space, dead end = area less than 1/2 total
-- TODO: alternative idea: dead end when all search stop is due to SNAKE BODY
deadEndScore : World -> Direction -> (Score, Bool)
deadEndScore world d =
    let
        maxSteps = (world.size.w * world.size.h - world.snake.length) // 2
        start = world.snake |> Snake.turn d |> Snake.nextBodyCell
        filledRegion = fill world maxSteps [start] Set.empty
        filledArea = Set.size filledRegion
        isDeadEnd = filledArea < maxSteps
        score = if isDeadEnd then filledArea else scoreSafe
    in
        (score, isDeadEnd)

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
                        else if WorldAux.cellInSnakeBody cell world then
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
