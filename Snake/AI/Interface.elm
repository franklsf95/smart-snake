-- AI Drunk
module Snake.AI.Interface where

import Random

{- AI Auxiliary State -}

type alias AIState =
    { seed : Random.Seed
    }

initialAuxilaryState : AIState
initialAuxilaryState =
    { seed = Random.initialSeed 3
    }
