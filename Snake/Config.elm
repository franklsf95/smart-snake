module Snake.Config where

import Snake.AI.Interface as AI
import Color

arenaWidth = 15
arenaHeight = 10
cellSize = 40
colorBackground = Color.rgb 62 56 64
colorBody = Color.rgb 110 211 207
colorFood = Color.rgb 230 39 57
enableAI = True
fps = 300
initialRandomSeed = 42
scoreFood = 100
scoreInitial = scoreFood * snakeInitialLength
scoreMove = -1
snakeInitialLength = 6

-- Color palette: http://www.colourlovers.com/palette/4094210/Invincible_3.0
