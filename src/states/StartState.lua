--[[
    Represents the state the game is in when we've just started;
    should simply display "Bust-out" in large text,
    as well as a message to press Enter to begin
]]

--__includes means we will inherit from BaseState so 
--all states have what we need

StartState = Class{__includes = BaseState}

--Which option on the menu we are highlighting
local highlighted = 1

function StartState:enter(params)
    self.highScores = params.highScores
end

function StartState:update(dt)
    --toggle highlighted option if we press a button
    if love.keyboard.wasPressed('up') or love.keyboard.wasPressed('down') then
        if highlighted == 1 then
            highlighted = 2

        elseif highlighted == 2 then
            highlighted = 1
        end
        gSounds['paddle-hit']:play()
    end

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gSounds['confirm']:play()

        if highlighted == 1 then
            gStateMachine:change('serve', {
                paddle = Paddle(1),
                bricks = LevelMaker.createMap(1),
                health = 3,
                score = 0,
                level = 1
            })

        else
            gStateMachine:change('high-scores', {
                highScores = self.highScores
            })
        end
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function StartState:render()
    --title
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf("BUST-OUT", 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, 'center')
    --instructions
    love.graphics.setFont(gFonts['medium'])

    --if highlighting 1, render that option blue
    if highlighted == 1 then
        love.graphics.setColor(103/255, 1, 1, 1)

    end
    love.graphics.printf("START", 0, VIRTUAL_HEIGHT / 2 + 70, VIRTUAL_WIDTH, 'center')
    
    --reset the color
    love.graphics.setColor(1, 1, 1, 1)

    if highlighted == 2 then
        love.graphics.setColor(103/255, 1, 1, 1)
    end
    love.graphics.printf("HIGH SCORES", 0, VIRTUAL_HEIGHT / 2 + 90, VIRTUAL_WIDTH, 'center')

    --reset the color
    love.graphics.setColor(1, 1, 1, 1)
end