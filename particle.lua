constants = require("constants")

imageSpeedLine = love.graphics.newImage("resources/images/speedLine.png")

local particle = {}

particle.smoke = {}
particle.speedLines = {}

local maxParticles = 1000

local function getSmoke()
    local imageData = love.image.newImageData(1, 1)
    imageData:setPixel(0, 0, 0.8, 0.8, 0.8, 0.5)
    local image = love.graphics.newImage(imageData)

    local particleSystem = love.graphics.newParticleSystem(image, 1000)
    particleSystem:setParticleLifetime(.7, 1)
    particleSystem:setSizes(2, 4)
    particleSystem:setSpread(0.5)
    particleSystem:setSpeed(20, 30)

    return particleSystem
end

local function updateSmoke(plane, dt)
    particle.smoke:setPosition(plane.x, plane.y)
    particle.smoke:setDirection(math.rad(plane.angle + 90))
    particle.smoke:setEmissionRate(plane.engineOn and plane.throttle * 100 or 0)

    particle.smoke:update(dt)
end

local function getSpeedLines()
    local particleSystem = love.graphics.newParticleSystem(imageSpeedLine, 1000)
    particleSystem:setEmissionArea('normal', 0, 5)
    particleSystem:setParticleLifetime(0.1, 0.2)
    particleSystem:setSizes(1, 1)
    particleSystem:setSpeed(200)

    return particleSystem
end

local function updateSpeedLines(plane, dt)
    particle.speedLines:setPosition(plane.x, plane.y)
    particle.speedLines:setDirection(math.rad(plane.angle + 90))
    particle.speedLines:setEmissionRate(plane.speed >= constants.windThreshold and plane.speed / 4 or 0)

    particle.speedLines:update(dt)
end

function particle.init()
    particle.smoke = getSmoke()
    particle.speedLines = getSpeedLines()
end

function particle.update(plane, dt)
    updateSmoke(plane, dt)
    updateSpeedLines(plane, dt)
end

return particle
