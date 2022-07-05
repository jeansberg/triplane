local animation = require("animation")
local particle = require("particle")
local audio = require("audio")
local flipState = require("flipState")
local mathFunc = require("mathFunc")

local imageSide = love.graphics.newImage("resources/images/plane_side.png")
local imageTop = love.graphics.newImage("resources/images/plane_top.png")
local imageBottom = love.graphics.newImage("resources/images/plane_bottom.png")
local imageWreck = love.graphics.newImage("resources/images/plane_wreck.png")

local plane = {}

local controlKey = {
    UP = 'up',
    DOWN = 'down',
    LEFT = 'left',
    RIGHT = 'right',
    FLIP = 'f'
}

local stickState = {
    BACK = -1,
    NEUTRAL = 0,
    FORWARD = 1
}

local flipCooldownMax = 0.5
local flipAnimationTimerMax = 0.2
local engineCooldownMax = 2

function plane.init(x, y, throttle)
    plane.x = x
    plane.y = y
    plane.engineOn = 1
    plane.stick = 0
    plane.angle = 90
    plane.throttle = throttle
    plane.speed = 100
    plane.destroyed = false
    plane.grounded = false
    plane.lastXSpeed = 0
    plane.lastYSpeed = 0

    plane.flipState = flipState.NONE
    plane.flipCooldown = flipCooldownMax
    plane.flipAnimationTimer = flipAnimationTimerMax

    plane.engineCooldown = engineCooldownMax

    plane.smoke = particle.createSmoke()
    plane.speedlines = particle.createSpeedlines()
    plane.explosion = { particleSystems = {} }
end

function plane.draw()
    local image
    if plane.destroyed then
        image = imageWreck
    elseif plane.flipState == flipState.FLIPPING then
        image = imageTop
    elseif plane.flipState == flipState.FLIPPING_BACK then
        image = imageBottom
    else
        image = imageSide
    end

    if plane.flipState == flipState.NONE then
        love.graphics.draw(image, plane.x, plane.y, math.rad(plane.angle - 90), 0.2, 0.2, image:getWidth() / 2,
            image:getHeight() / 2)
    else
        love.graphics.draw(image, plane.x, plane.y, math.rad(plane.angle - 90), 0.2, -0.2, image:getWidth() / 2,
            image:getHeight() / 2)
    end

    for _, p in pairs(plane.explosion.particleSystems) do
        love.graphics.draw(p, 0, 0)
    end

    if plane.destroyed then
        return
    end

    love.graphics.draw(plane.smoke, 0, 0)
    love.graphics.draw(plane.speedlines, 0, 0)
end

function plane.toggleEngine()
    if plane.destroyed then
        return
    end

    plane.engineOn = not plane.engineOn
    if not plane.engineOn then
        audio.playTurnoff()
        plane.throttle = 0.5
    else
        audio.playTurnon()
    end
end

function love.keypressed(key)
    if key == controlKey.FLIP and plane.flipCooldown >= flipCooldownMax then
        animation.startFlip(plane)
    elseif key == 'r' then
        plane.init(20, 400, 1)
    elseif key == 'e' and plane.engineCooldown > engineCooldownMax then
        plane.engineCooldown = 0
        plane.toggleEngine()
    end
end

local function updateParticles(dt)
    particle.updateSmoke(plane.smoke, plane.engineOn and plane.throttle + 0.1 or 0, plane.x, plane.y, plane.angle, dt)
    particle.updateSpeedlines(plane.speedlines, plane, dt)
    particle.updateExplosions(plane.explosion, dt)
end

function plane.update(dt)
    updateParticles(dt)

    if plane.engineOn then
        audio.playEngine(plane.throttle)

        if love.keyboard.isDown(controlKey.UP) then
            plane.throttle = math.min(2, plane.throttle + dt)
        elseif love.keyboard.isDown(controlKey.DOWN) then
            plane.throttle = math.max(plane.throttle - dt, 0)
        end
    end

    if not plane.destroyed then
        audio.playWind(plane.speed)
        updateTimers(plane, dt)
        animation.updateFlip(plane)
    end

    if not plane.destroyed then
        if love.keyboard.isDown(controlKey.LEFT) then
            plane.stick = plane.flipState == flipState.FLIPPED and stickState.FORWARD or stickState.BACK
        elseif love.keyboard.isDown(controlKey.RIGHT) then
            plane.stick = plane.flipState == flipState.FLIPPED and stickState.BACK or stickState.FORWARD
        else
            plane.stick = stickState.NEUTRAL
        end
    end

    plane.speed = getSpeed(plane.speed, plane.throttle, plane.engineOn, plane.angle, dt)


    if plane.grounded then
        plane.y = 635
        plane.angle = mathFunc.lerp(plane.angle, 90, dt)

        plane.x = plane.x + dt * plane.lastXSpeed * 0.75

        plane.lastXSpeed = mathFunc.lerp(plane.lastXSpeed, 0, dt)
    else
        plane.angle = getAngle(plane.angle, plane.stick, plane.speed, dt)

        local speed = plane.speed
        local xSpeed = math.cos(math.rad(plane.angle - 90)) * speed
        local ySpeed = math.sin(math.rad(plane.angle - 90)) * speed

        plane.lastXSpeed = xSpeed
        plane.lastYSpeed = ySpeed

        plane.x = plane.x + xSpeed * dt
        plane.y = plane.y + ySpeed * dt
    end
end

function getSpeed(speed, throttle, engineOn, angle, dt)
    local gravityMod = math.cos(math.rad(angle)) * 300
    local throttleModifier = engineOn and 100 or 0
    local targetSpeed
    if gravityMod < 0 then
        targetSpeed = throttle * throttleModifier - gravityMod
        return mathFunc.lerp(speed, targetSpeed, dt)
    else
        targetSpeed = throttle * throttleModifier - gravityMod
        return mathFunc.lerp(speed, targetSpeed, dt / 2)
    end
end

function getAngle(angle, stick, speed, dt)
    local newAngle
    if stick == stickState.FORWARD then
        newAngle = angle + dt * 100
    elseif stick == stickState.BACK then
        newAngle = angle - dt * 100
    else
        newAngle = angle
    end

    if math.abs(newAngle) >= 360 and stick == stickState.FORWARD then
        newAngle = 0
    elseif newAngle <= 0 and stick == stickState.BACK then
        newAngle = 360
    end

    -- Start diving if speed is too low
    if speed < 50 then
        if angle < 180 then
            newAngle = mathFunc.lerp(newAngle, newAngle + 4, dt * 10)
        else
            newAngle = mathFunc.lerp(newAngle, newAngle - 4, dt * 10)
        end
    end

    return newAngle
end

function updateTimers(plane, dt)
    if plane.flipCooldown <= flipCooldownMax then
        plane.flipCooldown = plane.flipCooldown + dt
    end

    if plane.flipAnimationTimer <= flipAnimationTimerMax then
        plane.flipAnimationTimer = plane.flipAnimationTimer + dt
    end

    if plane.engineCooldown <= engineCooldownMax then
        plane.engineCooldown = plane.engineCooldown + dt
    end
end

function plane.getCollisionBox()
    local x = plane.x
    local y = plane.y
    local width = 280 / 5
    local height = 142 / 5

    return {
        x = x - width,
        y = y - height,
        width = width,
        height = height
    }
end

function plane.handleCollision(object)
    if plane.destroyed then
        return
    end

    if object.isMap then
        plane.grounded = true
        plane.destroyed = true
        plane.engineOn = false

        audio.playExplosion()
        audio.killSound()
        plane.explosion = particle.createExplosionSystems(plane.x, plane.y, plane.lastXSpeed)
    end
end

return plane
