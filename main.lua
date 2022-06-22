audio = require("audio")
controls = require("controls")
plane = require("plane")
map = require("map")

function love.load()
    timer = 0

    plane.init(20, 400, 1)
    love.window.setMode(1024, 768)
end

function love.draw()
    love.graphics.setColor(0.2, 0.2, 1, 1)
    love.graphics.rectangle("fill", 0, 0, 1024, 768)
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.rectangle("fill", 900, 700 - plane.throttle * 100, 20, 40)
    love.graphics.print(math.ceil(plane.throttle * 100), 850, 600)

    map.draw()
    plane.draw()
end

function love.update(dt)
    timer = timer + dt
    -- controls.update(dt, setThrottle)
    audio.playEngine(1 + plane.throttle * 0.3 - 0.5)
    audio.playWind(plane.speed)
    plane.update(dt)
end
