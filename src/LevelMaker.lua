--[[
    Creates randomized levels for the game. Returns a table of bricks the game can render
]]

LevelMaker = Class{}

--[[
    Creates a table of bricks to be returned to the main game, with
    different ways of randomizing rows and columns of bricks.
    ]]

function LevelMaker.createMap(level)
    bricks = {}

    local numRows = math.random(1, 5)
    local numCols = math.random(7, 13)

    for y = 1, numRows do
        for x = 1, numCols do
            b = Brick(--calculate x-coordinate
                        (x-1) * 32 + 8 + (13 - numCols) * 16,
                    y * 16)
                    
            table.insert(bricks, b)
        end
    end
    return bricks
end