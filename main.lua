controls = require("controls")
plane = require("plane")
map = require("map")

function love.load()
    plane.init(20, 400, 1, toggleEngine)
    love.window.setMode(1024, 768)
end

function love.draw()
    map.draw()
    plane.draw()
    drawControls()
end

function drawControls()
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("line", 880, 650, 20, 70)
    love.graphics.rectangle("fill", 870, 720 - plane.throttle * 40, 40, 10)

    love.graphics.rectangle("line", 930, 660, 20, 50)
    love.graphics.circle("fill", 940, 685 - plane.stick * 20, 15)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print('Throttle: ' .. math.ceil(plane.throttle * 50), 780, 665)
    love.graphics.print('Speed: ' .. math.ceil(plane.speed), 780, 685)
    love.graphics.print('Angle: ' .. math.ceil(plane.angle), 780, 705)
end

function love.update(dt)
    checkCollisions(plane, map)
    checkCollisions(map, plane)

    plane.update(dt)
end

function checkCollisions(object1, object2)
    local r1 = object1.getCollisionBox()
    local r2 = object2.getCollisionBox()

    local xIntersect = r1.x + r1.width > r2.x and r1.x < r2.x + r2.width
    local yIntersect = r1.y + r1.height > r2.y and r1.y < r2.y + r2.width

    if xIntersect and yIntersect then
        object1.handleCollision(r2)
        object2.handleCollision(r1)

        -- Return explosion so we cna draw it
    end
end
