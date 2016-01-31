module Snake.Game where

import Snake.Model.Snake as Snake
import Snake.Model.World exposing (World)
import Snake.Control as Control
import Signal

initialWorld : World
initialWorld =
    let
        size = { w = 30, h = 20 }
    in
        { size = size
        , snake = Snake.initialSnake 6 size
        , food = { x = 3, y = 5 }
        }


updateWorld : Control.Input -> World -> World
updateWorld input world =
    case input of
        Control.Tick ->
            { world | snake = Snake.move world.snake }
        _ ->
            Debug.crash "todo"

worldSignal : Signal World
worldSignal = Signal.foldp updateWorld initialWorld Control.inputSignal

{- Game -}

--type alias Game =
--    { world : World
--    , alive : Bool
--    , score : Int
--    }

--isGameOver : World -> Bool
--isGameOver _ = False
