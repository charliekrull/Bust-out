--[[
    A brick, the target. Different colored bricks
    have different point values. 
]]

Brick = Class{}

function Brick:init(x, y)
    --used for coloring and score calculation
    self.tier = 0
    self.color = 1

    self.x = x
    self.y = y
    self.width = 32
    self.height = 16
    --should this brick be rendered and updated
    self.inPlay = true
end
--[[
    triggers a hit on the brick, taking it out of play if at 0 health or 
    changing color otherwise
]]
function Brick:hit()
    --play the sound
    gSounds['brick-hit-2']:play()

    self.inPlay = false
end

function Brick:render()
    if self.inPlay then
        love.graphics.draw(gTextures['main'],
    --multiply color - 1  by 4 to get the color offset, then add tier to that
    --draw correct block
            gFrames['bricks'][1+((self.color - 1) * 4) + self.tier],
            self.x, self.y)
    end
end