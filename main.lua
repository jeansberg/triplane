audio = require("audio")
controls = require("controls")
plane = require("plane")
map = require("map")

local toggleEngine = function()
    plane.engineOn = not plane.engineOn
    if not plane.engineOn then
        audio.playTurnoff()
        plane.throttle = 0.5
    else
        audio.playTurnon()
    end
end

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
    if plane.engineOn then
        audio.playEngine(plane.throttle)
    end

    audio.playWind(plane.speed)
    plane.update(dt)
end

