animation = require("animation")
particle = require("particle")
audio = require("audio")
flipState = require("flipState")

imageSide = love.graphics.newImage("resources/images/plane_side.png")
imageTop = love.graphics.newImage("resources/images/plane_top.png")
imageBottom = love.graphics.newImage("resources/images/plane_bottom.png")

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

    plane.flipState = flipState.NONE
    plane.flipCooldown = flipCooldownMax
    plane.flipAnimationTimer = flipAnimationTimerMax

    plane.engineCooldown = engineCooldownMax

    particle.init()

    plane.smokeSystem = particle.smoke
    plane.speedLineSystem = particle.speedLines
end

function plane.draw()
    for _, value in pairs(particle.explosions) do
        love.graphics.draw(value, 0, 0)
    end

    if plane.destroyed then
        return
    end

    love.graphics.draw(plane.smokeSystem, 0, 0)
    love.graphics.draw(plane.speedLineSystem, 0, 0)

    if plane.flipState == flipState.FLIPPING then
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

    local x = plane.x
    local y = plane.y
    local width = 280 / 5
    local height = 142 / 5

    --[[     love.graphics.setColor(1, 0, 0)
    love.graphics.points(x - width / 2, y - height / 2, x + width / 2, y - height / 2, x + width / 2, y + height / 2,
        x - width / 2, y + height / 2)
    love.graphics.setColor(1, 1, 1) ]]
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
    elseif key == 'x' then
        particle.addExplosion(400, 400)
    end
end

function plane.update(dt)
    particle.update(plane, dt)

    if plane.destroyed then
        return
    end

    if plane.engineOn then
        audio.playEngine(plane.throttle)
    end

    audio.playWind(plane.speed)

    updateTimers(plane, dt)

    animation.updateFlip(plane)

    if plane.engineOn then
        if love.keyboard.isDown(controlKey.UP) then
            plane.throttle = math.min(2, plane.throttle + dt)
        elseif love.keyboard.isDown(controlKey.DOWN) then
            plane.throttle = math.max(plane.throttle - dt, 0)
        end
    end

    if love.keyboard.isDown(controlKey.LEFT) then
        plane.stick = plane.flipState == flipState.FLIPPED and stickState.FORWARD or stickState.BACK
    elseif love.keyboard.isDown(controlKey.RIGHT) then
        plane.stick = plane.flipState == flipState.FLIPPED and stickState.BACK or stickState.FORWARD
    else
        plane.stick = stickState.NEUTRAL
    end

    plane.speed = getSpeed(plane.speed, plane.throttle, plane.engineOn, plane.angle, dt)
    plane.angle = getAngle(plane.angle, plane.stick, plane.speed, dt)

    delta = dt * plane.speed
    deltaX = math.cos(math.rad(plane.angle - 90)) * delta
    deltaY = math.sin(math.rad(plane.angle - 90)) * delta

    plane.x = plane.x + deltaX
    plane.y = plane.y + deltaY
end

function getSpeed(speed, throttle, engineOn, angle, dt)
    local gravityMod = math.cos(math.rad(angle)) * 300
    local throttleModifier = engineOn and 100 or 0
    if gravityMod < 0 then
        targetSpeed = throttle * throttleModifier - gravityMod
        return lerp(speed, targetSpeed, dt)
    else
        targetSpeed = throttle * throttleModifier - gravityMod
        return lerp(speed, targetSpeed, dt / 2)
    end
end

function getAngle(angle, stick, speed, dt)
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
            newAngle = lerp(newAngle, newAngle + 4, dt * 10)
        else
            newAngle = lerp(newAngle, newAngle - 4, dt * 10)
        end
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

function plane.handleCollision(rect)
    if plane.destroyed then
        return
    end

    plane.destroyed = true

    audio.playExplosion()
    audio.killSound()
    particle.addExplosion(plane.x, plane.y)
end

return plane
