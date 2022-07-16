--[[
    A ball that bounces back and forth between the sides of the world space,
    the paddle, and the bricks. The ball can have a skin, chosen at random for the moment
]]

Ball = Class{}

function Ball:init(skin)
    self.width = 8
    self.height = 8

    --for keeping track of velocity on both the x and y axes
    self.dy = 0
    self.dx = 0

    --this will be the color of the our ball, and we will index
    --our table of Quads relating to the global block texture using this
    self.skin = skin
end

--[[
    Expects and argument with a bounding box like a paddle or brick,
    returns true if the bounding boxes of this and the argument overlap
]]

function Ball:collides(target)
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end

    return true
end

--[[
    Places ball in the middle of the screen with no movement.
]]

function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2
    self.dx = 0
    self.dy = 0
end

function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

    --make ball bounce off walls
    if self.x <= 0 then
        self.x = 0
        self.dx = -self.dx
        gSounds['wall-hit']:play()
    end

    if self.x >= VIRTUAL_WIDTH - 8 then
        self.x = VIRTUAL_WIDTH - 8
        self.dx = - self.dx
        gSounds['wall-hit']:play()
    end

    if self.y <= 0 then
        self.y = 0
        self.dy = -self.dy
        gSounds['wall-hit']:play()
    end

end

function Ball:render()
    --gTextures['main'] is the global texture for all blocks, ball included
    love.graphics.draw(gTextures['main'], gFrames['balls'][self.skin], self.x, self.y)
end