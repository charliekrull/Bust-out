--[[
    The state wherein the player can move the paddle left and right with 
    the ball, while the game waits for them to serve.
]]

ServeState = Class{__includes = BaseState}

function ServeState:enter(params)
    --grab game state from params
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.level = params.level

    --init new ball (random color why not?)
    self.ball = Ball()
    self.ball.skin = math.random(7)
end

function ServeState:update(dt)
    self.paddle:update(dt)
    self.ball.x = self.paddle.x + (self.paddle.width / 2) - 4
    self.ball.y = self.paddle.y - self.ball.width

    if love.keyboard.wasPressed('space') then
        --pass in all important info to the PlayState
        gStateMachine:change('play', {
            paddle = self.paddle,
            bricks = self.bricks,
            health = self.health,
            score = self.score,
            ball = self.ball,
            level = self.level
        })
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function ServeState:render()
    self.paddle:render()
    self.ball:render()

    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    renderScore(self.score)
    renderHealth(self.health)

    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Press Space to Serve!', 0, VIRTUAL_HEIGHT/2,
        VIRTUAL_WIDTH, 'center')
end