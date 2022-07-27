--[[
    Spawns randomly in a block. When the block is broken, the powerup
    is released and descends. If the paddle touches it, they get the powerup
]]

Powerup = Class{}

function Powerup:init(name, x, y)
    self.name = name
    self.x = x
    self.y = y
    self.dy = 50
    self.width = 16
    self.height = 16
    
    --whether to remove from the scene
    self.remove = false
end

function Powerup:collides(target)
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end

    return true
end


function Powerup:update(dt)
    self.y = self.y + self.dy * dt

    if self.y > VIRTUAL_HEIGHT + 4 then
        self.remove = true
    end

end

function Powerup:render()
    love.graphics.draw(gTextures['main'], gFrames['powerups'][self.name], self.x, self.y)
end