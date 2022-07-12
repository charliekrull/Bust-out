--[[
    The PlayState Class
    The class so classy it has 4 capital letters in its 3-word name

    the state of the game in which we are actively playing. Player controls the paddle,
    with the ball bouncing around hitting stuff. IF the ball goes below the paddle then
    the player should lose one point of health and be taken to the Game Over Screen
    if at 0 health and or the Serve screen otherwise
    
]]

PlayState = Class{__includes = BaseState}

function PlayState:init()
    self.paddle = Paddle()
    self.paused = false
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()

        else
            return
        end

    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return    
    
    end

    self.paddle:update(dt)

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    self.paddle:render()

    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf('PAUSED', 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end