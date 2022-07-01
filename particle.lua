constants = require("constants")

imageSpeedLine = love.graphics.newImage("resources/images/speedLine.png")
imageScrap = love.graphics.newImage("resources/images/scrap.png")
imageScrap2 = love.graphics.newImage("resources/images/scrap2.png")
imageScrap3 = love.graphics.newImage("resources/images/scrap3.png")

local particle = {}

particle.smoke = {}
particle.speedLines = {}
particle.explosions = {}

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

function particle.addExplosion(x, y)
    local imageData = love.image.newImageData(10, 1)
    for i = 0, 9 do
        imageData:setPixel(i, 0, 1, 0.5, 0, 1)
    end
    local image = love.graphics.newImage(imageData)

    local particleSystem = love.graphics.newParticleSystem(image, 2000)
    particleSystem:setParticleLifetime(0.1)
    particleSystem:setSizes(5, 2)
    particleSystem:setSpeed(500)
    particleSystem:setPosition(x, y)

    particleSystem:setDirection(math.rad(90))
    particleSystem:setSpread(math.rad(360))
    particleSystem:setRelativeRotation(true)
    particleSystem:setEmitterLifetime(0.1)
    particleSystem:setEmissionRate(1000)

    table.insert(particle.explosions, particleSystem)

    particle.addScrapExplosion(x, y, 15, imageScrap)
    particle.addScrapExplosion(x, y, 15, imageScrap2)
    particle.addScrapExplosion(x, y, 5, imageScrap3)
    particle.addSmokePillar(x, y)
end

function particle.addScrapExplosion(x, y, number, image)
    local particleSystem = love.graphics.newParticleSystem(image, number)
    particleSystem:setParticleLifetime(1, 2)
    particleSystem:setSizes(0.1, 0.05)
    particleSystem:setSpeed(50, 75)
    particleSystem:setPosition(x, y)

    particleSystem:setSpin(2, 4)
    particleSystem:setLinearAcceleration(0, 50, 0, 100)
    particleSystem:setDirection(math.rad(90))
    particleSystem:setSpread(math.rad(360))
    particleSystem:setRelativeRotation(true)
    particleSystem:setEmitterLifetime(0.1)
    particleSystem:setEmissionRate(1000)

    table.insert(particle.explosions, particleSystem)
end

function particle.addSmokePillar(x, y, number)
    local imageData = love.image.newImageData(1, 1)
    imageData:setPixel(0, 0, 1, 1, 1, 1)
    local image = love.graphics.newImage(imageData)

    local particleSystem = love.graphics.newParticleSystem(image, 1000)
    particleSystem:setColors(1, 1, 0, 1, 1, 0.5, 0, 1, 0.5, 0.5, 0.5, 0.1)
    particleSystem:setParticleLifetime(1, 3)
    particleSystem:setSizes(5, 10)
    particleSystem:setDirection(math.rad(-90))
    particleSystem:setSpread(0.5)
    particleSystem:setSpeed(20, 30)
    particleSystem:setPosition(x, 635)

    particleSystem:emit(500)
    particleSystem:setEmissionRate(100)

    table.insert(particle.explosions, particleSystem)
end

local function updateExplosions(explosions, dt)
    for _, value in pairs(explosions) do
        value:update(dt)
    end
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
    particle.explosions = {}
end

function particle.update(plane, dt)
    updateSmoke(plane, dt)
    updateSpeedLines(plane, dt)
    print(table.getn(particle.explosions))
    updateExplosions(particle.explosions, dt)
end

return particle
