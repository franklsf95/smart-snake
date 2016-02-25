-- AI Greedy
module Snake.AI.Interface where

import Random

{- AI Auxiliary State -}

type alias AIState =
    { seed : Random.Seed
    , lastStepRandom : Bool
    }

initialAuxilaryState : AIState
initialAuxilaryState =
    { seed = Random.initialSeed 42
    , lastStepRandom = False
    }
