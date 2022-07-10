local plane = require("plane")
local map = require("map")

-- Keep a global variable for the player's plane
Player = {}

function love.load()
    player = plane.createPlayer(20, 400, 1)
    love.window.setMode(1920, 768)
end

local function drawControls()
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("line", 880, 650, 20, 70)
    love.graphics.rectangle("fill", 870, 720 - player.throttle * 40, 40, 10)

    love.graphics.rectangle("line", 930, 660, 20, 50)
    love.graphics.circle("fill", 940, 685 - player.stick * 20, 15)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print('Throttle: ' .. math.ceil(player.throttle * 50), 780, 665)
    love.graphics.print('Speed: ' .. math.ceil(player.speed), 780, 685)
    love.graphics.print('Angle: ' .. math.ceil(player.angle), 780, 705)
end

function love.draw()
    map.draw()
    plane.draw(player)
    drawControls()
end

local function checkCollisions(object1, object2)
    --[[     local r1 = object1.getCollisionBox()
    local r2 = object2.getCollisionBox()

    local xIntersect = r1.x + r1.width > r2.x and r1.x < r2.x + r2.width
    local yIntersect = r1.y + r1.height > r2.y and r1.y < r2.y + r2.width

    if xIntersect and yIntersect then
        object1.handleCollision(object2)
        object2.handleCollision(object1)
    end ]]
end

function love.update(dt)
    checkCollisions(player, map)
    checkCollisions(map, player)

    plane.update(player, dt)
end
