module Snake.Config where

import Snake.AI.Interface as AI
import Color

arenaWidth = 30
arenaHeight = 20
cellSize = 20
colorBackground = Color.rgb 62 56 64
colorBody = Color.rgb 110 211 207
colorFood = Color.rgb 230 39 57
enableAI = True
fps = 60
initialRandomSeed = 42
scoreFood = 100
scoreInitial = scoreFood * snakeInitialLength
scoreMove = -1
snakeInitialLength = 20

-- Color palette: http://www.colourlovers.com/palette/4094210/Invincible_3.0
