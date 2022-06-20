audio = require("audio")
controls = require("controls")
graphics = require("graphics")

function love.load()
  timer = 0
  throttle = 1

  love.window.setMode(800, 600)
end

function love.draw()
  love.graphics.rectangle("fill", 200, 200 - throttle * 100, 60,120)
  love.graphics.print(math.ceil(throttle*100), 300, 250)
end

function love.update(dt)
  timer=timer+dt
  controls.update(dt, setThrottle)
  audio.playEngine(throttle)
end

function setThrottle(mod)
  throttle = math.max(math.min(2, throttle + mod * 2), 0.5)
end