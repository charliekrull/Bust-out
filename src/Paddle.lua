--[[
    Paddle Class

    Represents a paddle that can move left and right. Used in the
    main program to deflect the ball toward the bricks. If the ball passes the paddle,
    the player loses one heart. The paddle can have a skin, which the player chooses right now
]]

Paddle = Class{}

--[[
    Paddle will initialize at the same spot every time, in the middle of the
    world horizontally, toward the bottom
]]

function Paddle:init()
    self.x = VIRTUAL_WIDTH / 2 - 32
    self.y = VIRTUAL_HEIGHT - 32

    --start with no velocity
    self.dx = 0
    --starting dimensions
    self.width = 64
    self.height = 16
    --the skin changes paddle color, used to offset us into gPaddleSkins later
    self.skin = 1
    --which of the four paddle sizes we currently are; 2 is the starting size, 1 up from the smallest
    self.size = 2
end

function Paddle:update(dt)
    --keyboard input
    if love.keyboard.isDown('left') then
        self.dx = -PADDLE_SPEED
    elseif love.keyboard.isDown('right') then
        self.dx = PADDLE_SPEED
    else
        self.dx = 0
    end

    --use math.max and math.min to clamp the paddle to the screen
    if self.dx < 0 then
        self.x = math.max(0, self.x + self.dx * dt)

    else
        self.x = math.min(VIRTUAL_WIDTH - self.width, self.x + self.dx * dt)
    end
end

--[[
    Render the paddle by drawing the main texture, passing in the quad that corresponds to proper skin and size
]]
function Paddle:render()
    love.graphics.draw(gTextures['main'], gFrames['paddles'][self.size + 4 * (self.skin - 1)],
        self.x, self.y)
end