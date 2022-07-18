--A remake of the endlessly remade 'Breakout'.
--Requires LOVE2D

require 'src/Dependencies'

--runs when the game first starts
function love.load()
    --nearest neighbor filtering, ie no filter
    love.graphics.setDefaultFilter('nearest', 'nearest')



    --seed the random number generator
    math.randomseed(os.time())

    --set the application title bar
    love.window.setTitle('Bust-out')

    --initialize the retro fonts provided by good old GD50
    gFonts = {
        ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
        ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
        ['large'] = love.graphics.newFont('fonts/font.ttf', 32)
    }

    --set the font to small to begin
    love.graphics.setFont(gFonts['small'])

    --load in all the pretty graphics we'll be using
    gTextures = {
        ['background'] = love.graphics.newImage('graphics/backgrounds/Background-1.png'),
        ['main'] = love.graphics.newImage('graphics/breakout.png'),
        ['arrows'] = love.graphics.newImage('graphics/arrows.png'),
        ['hearts'] = love.graphics.newImage('graphics/hearts.png'),
        ['particle'] = love.graphics.newImage('graphics/particle.png')
    }

    --Quads we will generate for all of our textures; Quads allow us
    --to show only part of a texture, not the whole thing
    gFrames = {
        ['paddles'] = GenerateQuadsPaddles(gTextures['main']),
        ['balls'] = GenerateQuadsBalls(gTextures['main']),
        ['bricks'] = GenerateQuadsBricks(gTextures['main']),
        ['hearts'] = GenerateQuads(gTextures['hearts'], 10, 9),
        ['arrows'] = GenerateQuads(gTextures['arrows'], 24, 24)
        
    }

    --setup our virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true 

    })

    --setup sound effects and music
    gSounds = {
        ['paddle-hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['brick-hit-1'] = love.audio.newSource('sounds/brick-hit-1.wav', 'static'),
        ['brick-hit-2'] = love.audio.newSource('sounds/brick-hit-2.wav', 'static'),
        ['confirm'] = love.audio.newSource('sounds/confirm.wav', 'static'),
        ['high-score'] = love.audio.newSource('sounds/high_score.wav', 'static'),
        ['hurt'] = love.audio.newSource('sounds/hurt.wav', 'static'),
        ['no-select'] = love.audio.newSource('sounds/no-select.wav', 'static'),
        ['pause'] = love.audio.newSource('sounds/pause.wav', 'static'),
        ['recover'] = love.audio.newSource('sounds/recover.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['select'] = love.audio.newSource('sounds/select.wav', 'static'),
        ['victory'] = love.audio.newSource('sounds/victory.wav', 'static'),
        ['wall-hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        
        ['music'] = love.audio.newSource('sounds/music.wav', 'static'),

    }

    --the state machine that will transition us between states, as it does 
    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end,
        ['play'] = function() return PlayState() end,
        ['serve'] = function() return ServeState() end,
        ['game-over'] = function() return GameOverState() end,
        ['victory'] = function () return VictoryState() end,
        ['high-scores'] = function() return HighScoreState() end,
        ['enter-high-score'] = function() return EnterHighScoreState() end,
        ['paddle-select'] = function() return PaddleSelectState() end
        
    }

    gStateMachine:change('start', {
        highScores = loadHighScores()
    })
    --a table we'll use to keep track of the keys pressed this frame,
    --and track input in other functions
    love.keyboard.keysPressed = {}
end

--defer resizing to push
function love.resize(w, h)
    push:resize(w, h)
end

--called every frame, uses dt to scale movement
function love.update(dt)
    gStateMachine:update(dt)

    --reset keysPressed
    love.keyboard.keysPressed = {}
end

--processes keystrokes as they happen 
--does not account for keys held down
function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
end

--function that lets us test for individual keystrokes outside the default love.keypressed callback
function love.keyboard.wasPressed(key)
    --returns true or false. if key was pressed, it will be true, else it will be false
    return love.keyboard.keysPressed[key]

end

--called each frame after update. draws all the screen stuff to the screen
function love.draw()
    push:apply('start') --start drawing at virtual resolution

    --background should be drawn regardless of state, scaled to fit virtual resolution
    local backgroundWidth = gTextures['background']:getWidth()
    local backgroundHeight = gTextures['background']:getHeight()

    love.graphics.draw(gTextures['background'], 0, 0, --at coordinates (0, 0)
        0, --no rotation
        VIRTUAL_WIDTH / (backgroundWidth - 1), --scale factors on the x and y axes
        VIRTUAL_HEIGHT / (backgroundHeight - 1))

    --render the current state to the screen
    gStateMachine:render()
    
    --display fps for debuggery. comment out to disable
    --displayFPS()
    
    push:apply('end') --stop drawing at virtual resolution
end

function loadHighScores()
    love.filesystem.setIdentity('breakout')
    --print the save directory to console
    dir = love.filesystem.getSaveDirectory()
    print(dir)

    --if the file doesn't exist, initialize it with default scores
    if not love.filesystem.getInfo('breakout.lst') then
        local scores = ''
        for i = 10, 1, -1 do
            scores = scores .. 'CCK\n'
            scores = scores .. tostring(i * 1000) .. '\n'
        end

        love.filesystem.write('breakout.lst', scores)
    end

    --flag for whether we're reading a name
    local name = true
    local currentName = nil
    local counter = 1

    --initilaize scores table with at least 10 blank entries
    local scores = {}

    for i = 1, 10 do
        scores[i] = {
            name = nil,
            score = nil
        }
    end

    --iterate over each line in the file filling in names and scores
    for line in love.filesystem.lines('breakout.lst') do
        if name then
            scores[counter].name = string.sub(line, 1, 3)
        else
            scores[counter].score = tonumber(line)
            counter = counter + 1
        end

        name = not name
    end

    return scores
end

function displayFPS()
    --simple little FPS display
    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 5, 5)
end

function renderHealth(health)
    local healthX = VIRTUAL_WIDTH - 100

    --render the amount of health
    for i = 1, health do
        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][1], healthX, 4)
        healthX= healthX + 11
    end

    for i= 1, 3 - health do
        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][2], healthX, 4)
        healthX = healthX + 11
    end
end

function renderScore(score)
    love.graphics.setFont(gFonts['small'])
    love.graphics.print('Score: '..tostring(score), VIRTUAL_WIDTH - 60, 5)
end
