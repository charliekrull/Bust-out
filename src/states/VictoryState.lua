--[[
    The state where we've beaten a level and are about to progress to the next
]]

VictoryState = Class{__includes = BaseState}

function VictoryState:enter(params)
    self.level = params.level
    self.score = params.score
    self.paddle = params.paddle
    self.health = params.health
    self.balls = params.balls
    self.highScores = params.highScores

    --reset paddle size so powerups go away
    self.paddle.size = 2
    self.paddle.width = 64
end

function VictoryState:update(dt)
    self.paddle:update(dt)
    --have the ball track the player
    self.balls[1].x = self.paddle.x + (self.paddle.width/2) - 4
    self.balls[1].y = self.paddle.y - 8

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('serve', {
            level = self.level + 1,
            bricks = LevelMaker.createMap(self.level + 1),
            paddle = self.paddle,
            health = self.health,
            score = self.score,
            highScores = self.highScores
        })
    end
end

function VictoryState:exit()
    local choice = math.random(1, 4) --every time a new level starts, get a new background image
    gTextures['background'] = gTextures['backgrounds'][choice]
end

function VictoryState:render()
    self.paddle:render()

    for k, ball in pairs(self.balls) do
        ball:render()
    end




    renderHealth(self.health)
    renderScore(self.score)
    --level complete text
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf("Level " .. tostring(self.level) .. " complete!",
        0, VIRTUAL_HEIGHT/4, VIRTUAL_WIDTH, 'center')

    --instructions text
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Press Enter to continue!', 0, VIRTUAL_HEIGHT/2, VIRTUAL_WIDTH, 'center')
end