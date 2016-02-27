module Snake.Model.Direction where

type Direction = Up | Down | Left | Right

insertTurn : Direction -> List Direction -> List Direction
insertTurn t ts =
    case ts of
        [] ->
            [t]
        h :: [] ->
            [h, t]
        old :: new :: [] ->
            [new, t]
        _ ->
            Debug.crash "multiple directions in lastTurns"
