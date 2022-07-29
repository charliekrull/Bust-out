--[[
    A brick, the target. Different colored bricks
    have different point values. 
]]

Brick = Class{}

paletteColors = {
    --blue
    [1] = {
        ['r'] = 99,
        ['g'] = 155,
        ['b'] = 255
    },

    --green
    [2] = {
        ['r'] = 106,
        ['g'] = 190,
        ['b'] = 47
    },

    --red 
    [3] = {
        ['r'] = 217,
        ['g'] = 87,
        ['b'] = 99
    },

    --purple
    [4] = {
        ['r'] = 215,
        ['g'] = 123,
        ['b'] = 186
    },

    --gold
    [5] = {
        ['r'] = 251,
        ['g'] = 242,
        ['b'] = 54
    },

    -- Locked/Black
    [6] = {
        ['r'] = 255,
        ['g'] = 255,
        ['b'] = 255
    }
}

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

    --whether this brick should spawn a powerup on its destruction
    self.hasPowerup = false

    --particle system belonging to the brick,
    --emitted on hit
    self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 64)
    --lasts 0.5 - 1 second
    self.psystem:setParticleLifetime(0.5, 1)

    --give it a generally downward acceleration
    self.psystem:setLinearAcceleration(-15, 0, 15, 80)

    --spread of particles; normals looks more natural than uniform; numbers are standard devation in X and Y axes
    self.psystem:setEmissionArea('normal', 10, 10)

    
end
--[[
    triggers a hit on the brick, taking it out of play if at 0 health or 
    changing color otherwise
]]
function Brick:hit()

    --set the particle system to interpolate between two colors;
    --in this case, self.color with varying alpha; brighter for highter tiers, fading to 0 over the particle lifetime
    self.psystem:setColors(
        paletteColors[self.color].r / 255,
        paletteColors[self.color].g / 255,
        paletteColors[self.color].b / 255,
        55 * (self.tier + 1) / 255,

        paletteColors[self.color].r / 255,
        paletteColors[self.color].g / 255,
        paletteColors[self.color].b / 255,
        0
    )
    self.psystem:emit(64)

    --play the sound
    gSounds['brick-hit-2']:stop()
    gSounds['brick-hit-2']:play()

    if self.color == 6 then
        self.inPlay = false
    

    elseif self.tier > 0 then 
        if self.color == 1 then
            self.tier = self.tier - 1
        else
            self.color = self.color - 1
        end
    else
        --if we're in the first tier of the base color, remove brick from play
        if self.color == 1 then
            self.inPlay = false
        else
            self.color = self.color - 1
        end
    end

    if not self.inPlay then --if brick is removed from play, play a second sound
        gSounds['brick-hit-1']:stop()
        gSounds['brick-hit-1']:play()
       
        
    end
end


function Brick:update(dt)
    self.psystem:update(dt)
end



function Brick:render()
    if self.inPlay then
        if self.color == 6 then
            love.graphics.draw(gTextures['main'], gFrames['bricks'][#gFrames['bricks']],
            self.x, self.y)
        
        else

            love.graphics.draw(gTextures['main'],
    --multiply color - 1  by 4 to get the color offset, then add tier to that
    --draw correct block
                gFrames['bricks'][1 + ((self.color - 1) * 4) + self.tier],
                self.x, self.y)
        end

            
    

        if self.hasPowerup then --if this block contains a powerup, draw a green box on it
            love.graphics.draw(gTextures['main'], gFrames['powerups']['label'],
            self.x + self.width/2 - 8, self.y)
        end
    end
end

--[[a separate render function for our particles so
    it can be called after all bricks are drawn]]

function Brick:renderParticles()
    love.graphics.draw(self.psystem, self.x + 16, self.y + 8)
end