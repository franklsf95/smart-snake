module Snake.Config where

type alias GameConfig =
    { arenaWidth : Int
    , arenaHeight : Int
    , enableAI : Bool
    , fps : Int
    , randomSeed : Int
    , scoreFood : Int
    , scoreInitial : Int
    , scoreMove : Int
    , snakeInitialLength : Int
    }

type alias RGB = (Int, Int, Int)

type alias VisualConfig =
    { cellSize : Int
    , colorBackground : RGB
    , colorBody : RGB
    , colorFood : RGB
    }

{- Default Configuration -}

defaultGameConfig : GameConfig
defaultGameConfig =
    { arenaWidth = 30
    , arenaHeight = 20
    , enableAI = True
    , fps = 30
    , randomSeed = 42
    , scoreFood = 100
    , scoreInitial = 600
    , scoreMove = -1
    , snakeInitialLength = 6
    }
