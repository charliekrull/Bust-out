--[[
    Creates randomized levels for the game. Returns a table of bricks the game can render
]]

LevelMaker = Class{}

--[[
    Creates a table of bricks to be returned to the main game, with
    different ways of randomizing rows and columns of bricks based on the level 
    the player has reached
    ]]

--global patterns. they make the whole level one pattern
NONE = 1
SINGLE_PYRAMID = 2
MULTI_PYRAMID = 3

--per row patterns
SOLID = 1
ALTERNATE = 2
SKIP = 3
NONE = 4

function LevelMaker.createMap(level)
    bricks = {}

    local numRows = math.random(1, 5)
    local numCols = math.random(7, 13)
    if numCols % 2 == 0 then
        numCols = numCols + 1
    end

    --highest possible brick spawned on a level, can't be above 3
    local highestTier = math.min(3, math.floor(level/5))

    --highest possible color
    local highestColor = math.min(5, level % 5 + 3)

    for y = 1, numRows do
        --whether to enable skipping:
        local skipPattern = math.random(1, 2) == 1 and true or false
        --whether to alternate color 
        local alternatePattern = math.random(1, 2) == 1 and true or false
        
        --choose 2 colors to alternate between
        local alternateColor1 = math.random(1, highestColor)
        local alternateColor2 = math.random(1, highestColor)
        local alternateTier1 = math.random(0, highestTier)
        local alternateTier2 = math.random(0, highestTier)

        --used when we want to skip blocks with skipPattern
        local skipFlag = math.random(2) == 1 and true or false

        --used when we want to alternate block color or tier
        local alternateFlag = math.random(2) == 1 and true or false

        --solid color used when not alternating
        local solidColor = math.random(1, highestColor)
        --solid tier used when not alternating
        local solidTier = math.random(0, highestTier)

        for x = 1, numCols do

            --if we're in a skipping pattern and it's a skip iteration
            if skipPattern and skipFlag then
                skipFlag = not skipFlag

                goto continue

            else
                skipFlag = not skipFlag
            end
            b = Brick(--calculate x-coordinate
                        (x-1) * 32 + 8 + (13 - numCols) * 16,
                    y * 16)

            if alternatePattern and alternateFlag then
                b.color = alternateColor1
                b.tier = alternateTier1
                alternateFlag = not alternateFlag
            else
                b.color = alternateColor2
                b.tier = alternateTier2
                alternateFlag = not alternateFlag
            end

            if not alternatePattern then
                b.color = solidColor
                b.tier = solidTier
            end
                    
            table.insert(bricks, b)

            ::continue:: --do nothing (because we are skipping a brick)
        end
    end


    if #bricks == 0 then
        return self.createMap(level)

    else
        return bricks
        
    end
end