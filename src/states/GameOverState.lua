--[[
    The state where we've lost all our health and it's time to display our score.

    Should transition to the EnterHighScoreState if we've exceeded one of our previous high scores
    Else back to StartState

]]

GameOverState = Class{__includes = BaseState}

function GameOverState:enter(params)
    self.score = params.score
end

function GameOverState:update(dt)
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('start')

    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function GameOverState:render()
    love.graphics.setFont(gFonts['large'])

    love.graphics.printf('GAME OVER', 0, VIRTUAL_HEIGHT/3, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf("Final Score: "..tostring(self.score), 0, VIRTUAL_HEIGHT/2, VIRTUAL_WIDTH, 'center')

    love.graphics.printf("Press Enter to restart", 0, VIRTUAL_HEIGHT * 0.75, VIRTUAL_WIDTH, 'center')


end
