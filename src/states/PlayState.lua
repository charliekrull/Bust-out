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

    --initialize ball, s

    self.balls = {params.ball}
    for k, ball in pairs(self.balls) do
        ball.dx = self.paddle.dx * 1.5
        ball.dy = -85 --for right now, serve straight up fairly slow
    end
    self.health = params.health
    self.score = params.score
    self.level = params.level
    self.highScores = params.highScores


    self.paused = false

    --use the "static" createMap function to generate a brick table
    self.bricks = params.bricks
    self.powerupsInPlay = {}
    self.hasKey = false

    self.lastServeTime = love.timer.getTime()
    self.lastUnPauseTime = love.timer.getTime()
    self.lastKeySpawnTime = love.timer.getTime()

    
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            self.lastUnPauseTime = love.timer.getTime()
            gSounds['pause']:play()
            gSounds['music']:play()
            

        else
            return
        end

    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        gSounds['music']:pause()
        return    
    
    end

    if lockBox then
        local timeSinceLastServe = love.timer.getTime() - self.lastServeTime
        local timeSinceLastUnPause = love.timer.getTime() - self.lastUnPauseTime
        local timeSinceLastKeySpawn = love.timer.getTime() - self.lastKeySpawnTime 

        if math.min(timeSinceLastServe, timeSinceLastUnPause, timeSinceLastKeySpawn) > 15 and not self.hasKey then --it's been 15 seconds
            --Spawn the key
            self.lastKeySpawnTime = love.timer.getTime()
            local keyx = math.random(0, VIRTUAL_WIDTH - 16)
            local keyy = math.random(0, VIRTUAL_HEIGHT / 2)
            local k = Powerup('key', keyx, keyy)
            table.insert(self.powerupsInPlay, k)

        end

    end

    self.paddle:update(dt)
    for k, ball in pairs(self.balls) do
        ball:update(dt)
    end

    for k, ball in pairs(self.balls) do
        if ball:collides(self.paddle) then
            --raise ball above paddle in case it goes below it, then reverse dy
                ball.y = self.paddle.y - 8
                ball.dy = -ball.dy

            --tweak angle of the bounce based on where it hits the paddle
            --if we hit the paddle on the left side moving left
            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                ball.dx = -50 + -(8 *(self.paddle.x + self.paddle.width / 2 - ball.x))
            
                --if we hit the paddle on the right side moving right
            elseif ball.x > self.paddle.x + (self.paddle.width/2) and self.paddle.dx > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width/2 - ball.x))
            
            end
            gSounds['paddle-hit']:play()
        end
    end

    --detect collision across all bricks with the ball
    for k, brick in pairs(self.bricks) do

        for l, ball in pairs(self.balls) do
        --only check collision if we're in play
            if brick.inPlay and ball:collides(brick) then
                if not (brick.color == 6) then
                
                    --trigger the brick's hit function, removing it from play or changing color
                    --score it
                    
                    
                    self.score = self.score + (brick.tier * 200 + brick.color * 25)

                    brick:hit()

                    if brick.hasPowerup and not brick.inPlay then
                        brick.hasPowerup = false
                        self:spawnPowerup(brick)

                    end

                    --check for victory because we've just hit a brick
                    if self:checkVictory() then
                        gSounds['victory']:play()

                        gStateMachine:change('victory', {
                            level = self.level,
                            paddle = self.paddle,
                            health = self.health,
                            score = self.score,
                            balls = self.balls,
                            highScores = self.highScores
                        })
                    end


                else --it's locked
                    if self.hasKey then
                        self.score = self.score + 3000

                        brick:hit()

                        if brick.hasPowerup and not brick.inPlay then
                            brick.hasPowerup = false
                            self:spawnPowerup(brick)
    
                        end
                        --good chance this will be the last one, as it's difficult to do.
                        --so check if we beat the level
                        --note the key will not carry from round to round (and it shouldn't be possible to finish with a key anyway)
                        if self:checkVictory() then
                            gSounds['victory']:play()
    
                            gStateMachine:change('victory', {
                                level = self.level,
                                paddle = self.paddle,
                                health = self.health,
                                score = self.score,
                                ball = self.balls[1],
                                highScores = self.highScores
                            })
                        end 
                    end
                end

                --collision code for bricks
                --check to see what side the ball hit through math

                --left edge
                if ball.x + 2 < brick.x and ball.dx > 0 then
                    
                    ball.dx = -ball.dx
                    ball.x = brick.x - ball.width
                --right edge
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                    ball.dx = -ball.dx
                    ball.x = brick.x + 32
                --top edge
                elseif ball.y < brick.y then
                    ball.dy = -ball.dy
                    ball.y = brick.y - ball.height

                else --it's a bottom collision
                    ball.dy = -ball.dy
                    ball.y = brick.y + 16
                end

                --speed up the ball a little in the y direction
                ball.dy = ball.dy * 1.03

                --only allow colliding with one brick, for corners
                break
            end
        end
    end

    for k, ball in pairs(self.balls) do
        if ball.y > VIRTUAL_HEIGHT then--player missed a ball 
            self.balls[k] = nil

            if not next(self.balls) then --self.balls is empty, ie no more in play
                self.health = self.health - 1 --this variant only deducts health when no balls are on screen
                gSounds['hurt']:play()
                
                
            
                gStateMachine:change('serve', {--otherwise, serve
                    paddle = self.paddle,
                    bricks = self.bricks,
                    health = self.health,
                    score = self.score,
                    highScores = self.highScores,
                    level = self.level,
                    hasKey = self.hasKey
                })

            
            end

            

                
            
            if self.health == 0 then --ran out of health, go to game over
                gStateMachine:change('game-over', {
                    score = self.score,
                    highScores = self.highScores
                })
                
            end
        end
    end

    --to render particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    for k, powerup in pairs(self.powerupsInPlay) do

        powerup:update(dt)
        
        

        if powerup:collides(self.paddle) then
            if powerup.name == 'shrink' then
                self.paddle.size = math.max(1, self.paddle.size - 1)
                self.paddle.width = math.max(32, self.paddle.width - 32)
                

            elseif powerup.name == 'grow' then
                self.paddle.size = math.min(4, self.paddle.size + 1)
                self.paddle.width = math.min(128, self.paddle.width + 32)
                

            elseif powerup.name == 'ball-speed-up' then
                for k, ball in pairs(self.balls) do
                    ball.dx = ball.dx * 1.2
                    ball.dy = ball.dy * 1.5
                end

            elseif powerup.name == 'multiball' then
                --spawn 2 more balls    
                local b = Ball(self.balls[1].skin)
                b.x = self.balls[1].x + 18
                b.y = self.balls[1].y
                b.dx = self.balls[1].dx + 70
                b.dy = self.balls[1].dy
                table.insert(self.balls, #self.balls + 1, b)

                b = Ball(self.balls[1].skin)
                b.x = self.balls[1].x - 34
                b.y = self.balls[1].y
                b.dx = self.balls[1].dx - 70
                b.dy = self.balls[1].dy
                table.insert(self.balls, #self.balls + 1, b)

                
            elseif powerup.name == 'key' then
                
                self.hasKey = true
                   
            end
            powerup.remove = true
        end

        if powerup.remove then
            self.powerupsInPlay[k] = nil
        end

        
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

    --render any powerups in play
    for k, powerup in pairs(self.powerupsInPlay) do
        powerup:render()
    end

    --render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()

    --render balls in play
    for k, ball in pairs(self.balls) do
        ball:render()
    end

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

function PlayState:spawnPowerup(brick)
    local choice = math.random(1, #gPowerupsList)
    local pow = Powerup(gPowerupsList[choice], brick.x + 8, brick.y)
    table.insert(self.powerupsInPlay, pow)
end