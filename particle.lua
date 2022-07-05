local constants = require("constants")
local mathFunc = require("mathFunc")

local imageSpeedLine = love.graphics.newImage("resources/images/speedLine.png")
local imageScrap = love.graphics.newImage("resources/images/scrap.png")
local imageScrap2 = love.graphics.newImage("resources/images/scrap2.png")
local imageScrap3 = love.graphics.newImage("resources/images/scrap3.png")

local particle = {}

function particle.createSmoke()
    local imageData = love.image.newImageData(1, 1)
    imageData:setPixel(0, 0, 0.8, 0.8, 0.8, 0.5)
    local smokePixel = love.graphics.newImage(imageData)

    local smoke = love.graphics.newParticleSystem(smokePixel, 1000)
    smoke:setParticleLifetime(.7, 1)
    smoke:setSizes(2, 4)
    smoke:setSpread(0.5)
    smoke:setSpeed(20, 30)

    return smoke
end

function particle.updateSmoke(smoke, throttle, x, y, angle, dt)
    smoke:setPosition(x, y)
    smoke:setDirection(math.rad(angle + 90))
    smoke:setEmissionRate(throttle * 100)

    smoke:update(dt)
end

function particle.createSpeedlines()
    local speedlines = love.graphics.newParticleSystem(imageSpeedLine, 1000)
    speedlines:setEmissionArea('normal', 0, 5)
    speedlines:setParticleLifetime(0.1, 0.2)
    speedlines:setSizes(1, 1)
    speedlines:setSpeed(200)

    return speedlines
end

function particle.updateSpeedlines(speedlines, plane, dt)
    speedlines:setPosition(plane.x, plane.y)
    speedlines:setDirection(math.rad(plane.angle + 90))
    speedlines:setEmissionRate(plane.speed >= constants.windThreshold and plane.speed / 4 or 0)

    speedlines:update(dt)
end

function particle.createExplosionSystems(x, y, deltaX)
    local initial = particle.addInitialBlast(x, y)
    local scrap1 = particle.getScrapExplosion(x, y, deltaX, 20, imageScrap)
    local scrap2 = particle.getScrapExplosion(x, y, deltaX, 20, imageScrap2)
    local scrap3 = particle.getScrapExplosion(x, y, deltaX, 10, imageScrap3)
    local smoke = particle.getSmokePillar(x, y, deltaX)

    return {particleSystems ={initial, scrap1, scrap2, scrap3, smoke}, dX = deltaX}
end

function particle.addInitialBlast(x, y)
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

    return particleSystem
end

function particle.getScrapExplosion(x, y, deltaX, number, image)
    local particleSystem = love.graphics.newParticleSystem(image, number * 2)
    particleSystem:setColors(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0)

    particleSystem:setParticleLifetime(1)
    particleSystem:setSizes(0.1, 0.12)
    particleSystem:setSpeed(50, 75)
    particleSystem:setPosition(x, y)

    particleSystem:setSpin(deltaX > 0 and 10 or -10)
    particleSystem:setLinearAcceleration(0, 100)
    particleSystem:setDirection(deltaX > 0 and math.rad(90) or math.rad(270))
    particleSystem:setSpread(math.rad(360))
    particleSystem:setRelativeRotation(true)
    particleSystem:setEmitterLifetime(1)

    particleSystem:emit(number / 2)
    particleSystem:setEmissionRate(number / 4)

    return particleSystem
end

function particle.getSmokePillar(x, y, deltaX, number)
    local imageData = love.image.newImageData(1, 1)
    imageData:setPixel(0, 0, 1, 1, 1, 1)
    local image = love.graphics.newImage(imageData)

    local particleSystem = love.graphics.newParticleSystem(image, 2000)
    particleSystem:setColors(1, 1, 0, 1, 1, 0.5, 0, 1, 0.5, 0.5, 0.5, 1, 0.5, 0.5, 0.5, 0)
    particleSystem:setParticleLifetime(2, 4)
    particleSystem:setSizes(5, 10)
    particleSystem:setDirection(math.rad(-90))
    particleSystem:setSpread(0.5)
    particleSystem:setSpeed(50, 10)
    particleSystem:setPosition(x, 635)
    particleSystem:setEmissionArea('normal', 3, 0)

    particleSystem:emit(150)
    particleSystem:setEmissionRate(450)

    return particleSystem
end

function particle.updateExplosions(explosions, dt)
    local dX = explosions.dX
    for i = #explosions.particleSystems, 1, -1 do
        local explosion = explosions.particleSystems[i]
        local x, y = explosion:getPosition()
        explosion:setPosition(x + dt * dX * 0.75, y)
        explosions.dX = mathFunc.lerp(dX, 0, dt)
        explosion:update(dt)
        if explosion:getCount() == 0 then
            table.remove(explosions.particleSystems, i)
        end
    end
    print (#explosions.particleSystems)
end

return particle
