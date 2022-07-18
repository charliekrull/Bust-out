--[[
    Allow the player to select the color of their paddle at the start of the game 
]]

PaddleSelectState = Class{__includes = BaseState}

function PaddleSelectState:enter(params)
    self.highScores = params.highScores
end

function PaddleSelectState:init()
    self.currentPaddle = 1
end

function PaddleSelectState:update(dt)
    if love.keyboard.wasPressed('left') then
        if self.currentPaddle == 1 then
            gSounds['no-select']:play()

        else
            gSounds['select']:play()
            self.currentPaddle = self.currentPaddle - 1
        end

    elseif love.keyboard.wasPressed('right') then
        if self.currentPaddle == 4 then
            gSounds['no-select']:play()

        else
            gSounds['select']:play()
            self.currentPaddle = self.currentPaddle + 1
        end        
    end

    --select paddle and move on to serve state
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gSounds['confirm']:play()

        gStateMachine:change('serve', {
            paddle = Paddle(self.currentPaddle),
            bricks = LevelMaker.createMap(1),
            health = 3,
            score = 0,
            highScores = self.highScores,
            level = 1
        })
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
    
end

function PaddleSelectState:render()
    --instructions
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf("Select your paddle with the left and right arrows!", 0, VIRTUAL_HEIGHT / 4,
        VIRTUAL_WIDTH, 'center')
    love.graphics.setFont(gFonts['small'])
    love.graphics.printf("Press Enter to continue!", 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, 'center')

    --left arrow. Should render normally if currentPaddle is above 1
    --if currentPaddle is 1 then it's shadowy to let us know we are as far "left" as we can go
    if self.currentPaddle == 1 then
        love.graphics.setColor(40/255, 40/255, 40/255, 128/255)
    end

    love.graphics.draw(gTextures['arrows'], gFrames['arrows'][1], VIRTUAL_WIDTH / 4 - 24,
        VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)

    --reset drawing to full white for proper rendering
    love.graphics.setColor(1, 1, 1, 1)

    --right arrow; should render normally is currentPaddle is less than 4.
    --at 4, it should be grayed out
    if self.currentPaddle == 4 then
        love.graphics.setColor(40/255, 40/255, 40/255, 128/255)
    end

    love.graphics.draw(gTextures['arrows'], gFrames['arrows'][2], VIRTUAL_WIDTH - VIRTUAL_WIDTH / 4,
        VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)

    love.graphics.setColor(1, 1, 1, 1)

    -- draw the paddle itself, based on which we have selected
    love.graphics.draw(gTextures['main'], gFrames['paddles'][2 + 4 * (self.currentPaddle - 1)],
        VIRTUAL_WIDTH / 2 - 32, VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)
end