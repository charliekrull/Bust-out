--[[
    The PlayState Class
    The class so classy it has 4 capital letters in its 3-word name

    the state of the game in which we are actively playing. Player controls the paddle,
    with the ball bouncing around hitting stuff. IF the ball goes below the paddle then
    the player should lose one point of health and be taken to the Game Over Screen
    if at 0 health and or the Serve screen otherwise
    
]]

PlayState = Class{__includes = BaseState}

function PlayState:enter(params)
    self.paddle = params.paddle

    --initialize ball with skin #1. Different skins = different sprites
    self.ball = params.ball
    --my twist on starting the ball. it will either go left, right or straight down
    self.ball.dx = math.random(200, 400) * math.random(-1, 1)
    self.ball.dy = math.random(-70, -85)
    self.health = params.health
    self.score = params.score
    self.level = params.level


    self.paused = false

    --use the "static" createMap function to generate a brick table
    self.bricks = params.bricks

    
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
    self.ball:update(dt)

    if self.ball:collides(self.paddle) then
        --raise ball above paddle in case it goes below it, then reverse dy
            self.ball.y = self.paddle.y - 8
            self.ball.dy = -self.ball.dy

        --tweak angle of the bounce based on where it hits the paddle
        --if we hit the paddle on the left side moving left
        if self.ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
            self.ball.dx = -50 + -(8 *(self.paddle.x + self.paddle.width / 2 - self.ball.x))
        
            --if we hit the paddle on the right side moving right
        elseif self.ball.x > self.paddle.x + (self.paddle.width/2) and self.paddle.dx > 0 then
            self.ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width/2 - self.ball.x))
        
        end
        gSounds['paddle-hit']:play()
    end
    --detect collision across all bricks with the ball
    for k, brick in pairs(self.bricks) do
    
        --only check collision if we're in play
        if brick.inPlay and self.ball:collides(brick) then
            
            --trigger the brick's hit function, removing it from play or changing color
            --score it
            brick:hit()
            self.score = self.score + (brick.tier * 200 + brick.color * 25)

            --check for victory because we've just hit a brick
            if self:checkVictory() then
                gSounds['victory']:play()

                gStateMachine:change('victory', {
                    level = self.level,
                    paddle = self.paddle,
                    health = self.health,
                    score = self.score,
                    ball = self.ball
                })
            end

            --collision code for bricks
            --check to see what side the ball hit through math

            --left edge
            if self.ball.x + 2 < brick.x and self.ball.dx > 0 then
                
                self.ball.dx = -self.ball.dx
                self.ball.x = brick.x - self.ball.width
            --right edge
            elseif self.ball.x + 6 > brick.x + brick.width and self.ball.dx < 0 then
                self.ball.dx = -self.ball.dx
                self.ball.x = brick.x + 32
            --top edge
            elseif self.ball.y < brick.y then
                self.ball.dy = -self.ball.dy
                self.ball.y = brick.y - self.ball.height

            else --it's a bottom collision
                self.ball.dy = -self.ball.dy
                self.ball.y = brick.y + 16
            end

            --speed up the ball a little in the y direction
            self.ball.dy = self.ball.dy * 1.03

            --only allow colliding with one brick, for corners
            break
        end
    end

    if self.ball.y > VIRTUAL_HEIGHT then --player missed
        self.health = self.health - 1
        gSounds['hurt']:play()

        if self.health == 0 then --ran out of health, go to game over
            gStateMachine:change('game-over', {
                score = self.score
            })

            
        else
            gStateMachine:change('serve', {--otherwise, serve
                paddle = self.paddle,
                bricks = self.bricks,
                health = self.health,
                score = self.score
            })
        end
    end

    --to render particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()

    --render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    --render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()
    self.ball:render()

    renderScore(self.score)
    renderHealth(self.health)

    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf('PAUSED', 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end
    end

    return true
end