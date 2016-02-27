-- AI Greedy
module Snake.AI.Interface where
import Snake.Model.Direction exposing (Direction(..))
import Random

{- AI Auxiliary State -}

type alias AIState =
    { seed : Random.Seed
    , lastStepRandom : Bool
    , lastTurn : Direction
    }

initialAuxilaryState : AIState
initialAuxilaryState =
    { seed = Random.initialSeed 42
    , lastStepRandom = False
    , lastTurn = Up
    }
