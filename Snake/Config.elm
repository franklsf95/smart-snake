module Snake.Config where

import Snake.AI.Interface as AI
import Color

initialLength = 6
arenaWidth = 30
arenaHeight = 20
cellSize = 20
colorBackground = Color.rgb 62 56 64
colorBody = Color.rgb 110 211 207
colorFood = Color.rgb 230 39 57
enableAI = True
scoreFood = 100
scoreInitial = scoreFood * initialLength
scoreMove = -1

-- Color palette: http://www.colourlovers.com/palette/4094210/Invincible_3.0
