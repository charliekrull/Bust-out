--[[
    All the goodies we need to get this party started

]]

--push allows us to draw the game at a lower resolution,
--for a retro aesthetic

push = require 'lib/push'

--The class library makes classes make sense to my brain
Class = require 'lib/class'

--Some global constants
require 'src/constants'

--the paddle as we know it
require 'src/Paddle'

--the ball as we throw it
require 'src/Ball'

--the bricks we throw it at
require 'src/Brick'

--powerups the player can get
require 'src/Powerup'

--A Basic state machine class that spreads the bugs across many files instead of one big one
require 'src/StateMachine'

--The think that makes the levels
require 'src/LevelMaker'

--utility functions for splitting sprite sheet into various Quads of differing sizes for the various components
--of our game
require 'src/Util'

--each of the individual states our game can be in
--each has its own render method called by our state machine each frame
require 'src/states/BaseState'
require 'src/states/StartState'
require 'src/states/PlayState'
require 'src/states/GameOverState'
require 'src/states/ServeState'
require 'src/states/VictoryState'
require 'src/states/HighScoreState'
require 'src/states/EnterHighScoreState'
require 'src/states/PaddleSelectState'