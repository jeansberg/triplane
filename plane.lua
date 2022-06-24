animation = require("animation")

imageSide = love.graphics.newImage("resources/images/plane_side.png")
imageTop = love.graphics.newImage("resources/images/plane_top.png")
imageBottom = love.graphics.newImage("resources/images/plane_bottom.png")
imageSpeedLine = love.graphics.newImage("resources/images/speedLine.png")

local plane = {}

local flipStates = {'none', 'flipped', 'flipping', 'flippingBack'}
local flipCooldownMax = 0.5
local flipAnimationTimerMax = 0.2

function plane.init(x, y, throttle)
    plane.x = x
    plane.y = y
    plane.stick = 0
    plane.angle = 90
    plane.throttle = throttle
    plane.speed = 100

    plane.flipState = 'none'
    plane.flipCooldown = flipCooldownMax
    plane.flipAnimationTimer = flipAnimationTimerMax

    plane.smokeSystem = getSmoke()
    plane.speedLineSystem = getSpeedLines()
end

function plane.draw()
    love.graphics.draw(plane.smokeSystem, 0, 0)
    love.graphics.draw(plane.speedLineSystem, 0, 0)

    if plane.flipState == 'flipping' then
        image = imageTop
    elseif plane.flipState == 'flippingBack' then
        image = imageBottom
    else
        image = imageSide
    end

    if plane.flipState == 'none' then
        love.graphics.draw(image, plane.x, plane.y, math.rad(plane.angle - 90), 0.2, 0.2, image:getWidth() / 2,
            image:getHeight() / 2)
    else
        love.graphics.draw(image, plane.x, plane.y, math.rad(plane.angle - 90), 0.2, -0.2, image:getWidth() / 2,
            image:getHeight() / 2)
    end
end

function love.keypressed(key)
    if key == "f" and plane.flipCooldown >= 0.5 then
        animation.startFlip(plane)
    end
end

function plane.update(dt)
    updateTimers(plane, dt)
    plane.smokeSystem:setPosition(plane.x, plane.y)
    plane.smokeSystem:setDirection(math.rad(plane.angle + 90))
    plane.smokeSystem:setEmissionRate(plane.throttle * 100)

    plane.smokeSystem:update(dt)

    plane.speedLineSystem:setPosition(plane.x, plane.y)
    plane.speedLineSystem:setDirection(math.rad(plane.angle + 90))
    plane.speedLineSystem:setEmissionRate(plane.speed >= 200 and plane.speed / 4 or 0)

    plane.speedLineSystem:update(dt)

    animation.updateFlip(plane)

    if love.keyboard.isDown("up") then
        plane.throttle = math.min(2, plane.throttle + dt)
    elseif love.keyboard.isDown("down") then
        plane.throttle = math.max(plane.throttle - dt, 0)
    end

    if love.keyboard.isDown("left") then
        plane.stick = plane.flipState == 'flipped' and 1 or -1
    elseif love.keyboard.isDown("right") then
        plane.stick = plane.flipState == 'flipped' and -1 or 1
    else
        plane.stick = 0
    end

    plane.speed = getSpeed(plane.speed, plane.throttle, plane.angle, dt)
    plane.angle = getAngle(plane.angle, plane.stick, plane.speed, dt)

    delta = dt * plane.speed
    deltaX = math.cos(math.rad(plane.angle - 90)) * delta
    deltaY = math.sin(math.rad(plane.angle - 90)) * delta

    plane.x = plane.x + deltaX
    plane.y = plane.y + deltaY
end

function getSpeed(speed, throttle, angle, dt)
    gravityMod = math.cos(math.rad(angle)) * 100
    targetSpeed = math.max(0, throttle * 100 - gravityMod)
    return lerp(speed, targetSpeed, dt)
end

function getAngle(angle, stick, speed, dt)
    if stick == 1 then
        newAngle = angle + dt * 100
    elseif stick == -1 then
        newAngle = angle - dt * 100
    else
        newAngle = angle
    end

    if math.abs(angle) >= 360 then
        angle = 0
    end

    return newAngle
end

function lerp(a, b, t)
    return a * (1 - t) + b * t
end

function updateTimers(plane, dt)
    if plane.flipCooldown <= flipCooldownMax then
        plane.flipCooldown = plane.flipCooldown + dt
    end

    if plane.flipAnimationTimer <= flipAnimationTimerMax then
        plane.flipAnimationTimer = plane.flipAnimationTimer + dt
    end
end

function getSmoke()
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

function getSpeedLines()
    local particleSystem = love.graphics.newParticleSystem(imageSpeedLine, 1000)
    particleSystem:setEmissionArea('normal', 0, 5)
    particleSystem:setParticleLifetime(0.1, 0.2)
    particleSystem:setSizes(1, 1)
    particleSystem:setSpread(0)
    particleSystem:setSpeed(100, 200)

    return particleSystem
end

return plane
