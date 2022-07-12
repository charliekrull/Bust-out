--[[
    GD50-style breakout remake.
]]

--[[
    Given an atlas, and the width and height of the tiles in it,
    split the texture into all of the quads by dividing it evenly
]]

function GenerateQuads(atlas, tilewidth, tileheight)
    local sheetWidth = atlas:getWidth() / tilewidth
    local sheetHeight = atlas:getHeight() / tileheight

    local sheetCounter = 1
    local spritesheet = {}

    for y = 0, sheetHeight - 1 do
        for x = 0, sheetWidth - 1 do
            spritesheet[sheetCounter] = love.graphics.newQuad(x * tilewidth, y * tileheight,
            tilewidth, tileheight, atlas:getDimensions())

            sheetCounter = sheetCounter + 1
        end
    end

    return spritesheet
end

function table.slice(tbl, first, last, step)
    local sliced = {}
    for i = first or 1, last or #tbl, step or 1 do
        sliced[#sliced+1] = tbl[i]
    end

    return sliced
end

--[[
    Specifically made to piece out the paddles from the sprite sheet. for this we have to piece out
    the paddles a bit manually, because they are different sizes
]]

function GenerateQuadsPaddles(atlas)
    local x = 0
    local y = 64

    local counter = 1
    local quads = {}

    for i = 0, 3 do
        --smallest paddles
        quads[counter] = love.graphics.newQuad(x, y, 32, 16, atlas:getDimensions())
        counter = counter + 1

        --medium
        quads[counter] = love.graphics.newQuad(x + 32, y, 64, 16, atlas:getDimensions())
        counter = counter + 1

        --large
        quads[counter] = love.graphics.newQuad(x+96, y, 96, 16, atlas:getDimensions())
        counter = counter + 1

        --huge
        quads[counter] = love.graphics.newQuad(x, y+16, 128, 16, atlas:getDimensions())
        counter = counter + 1

        x = 0
        y = y + 32

    end

    return quads
end