animation = require("animation")
particle = require("particle")
flipState = require("flipState")

imageSide = love.graphics.newImage("resources/images/plane_side.png")
imageTop = love.graphics.newImage("resources/images/plane_top.png")
imageBottom = love.graphics.newImage("resources/images/plane_bottom.png")
imageSpeedLine = love.graphics.newImage("resources/images/speedLine.png")

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

function plane.init(x, y, throttle)
    plane.x = x
    plane.y = y
    plane.stick = 0
    plane.angle = 90
    plane.throttle = throttle
    plane.speed = 100

    plane.flipState = flipState.NONE
    plane.flipCooldown = flipCooldownMax
    plane.flipAnimationTimer = flipAnimationTimerMax

    particle.init()

    plane.smokeSystem = particle.smoke
    plane.speedLineSystem = particle.speedLines
end

function plane.draw()
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

    -- drawPoints(plane, image)
end

function love.keypressed(key)
    if key == controlKey.FLIP and plane.flipCooldown >= 0.5 then
        animation.startFlip(plane)
    elseif key == 'r' then
        plane.init(20, 400, 1)
    end
end

function resetPlane()
    plane.init()
end

function plane.update(dt)
    updateTimers(plane, dt)

    particle.update(plane, dt)

    animation.updateFlip(plane)

    if love.keyboard.isDown(controlKey.UP) then
        plane.throttle = math.min(2, plane.throttle + dt)
    elseif love.keyboard.isDown(controlKey.DOWN) then
        plane.throttle = math.max(plane.throttle - dt, 0)
    end

    if love.keyboard.isDown(controlKey.LEFT) then
        plane.stick = plane.flipState == flipState.FLIPPED and stickState.FORWARD or stickState.BACK
    elseif love.keyboard.isDown(controlKey.RIGHT) then
        plane.stick = plane.flipState == flipState.FLIPPED and stickState.BACK or stickState.FORWARD
    else
        plane.stick = stickState.NEUTRAL
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
    gravityMod = math.cos(math.rad(angle)) * 300
    if gravityMod < 0 then
        targetSpeed = throttle * 100 - gravityMod
        return lerp(speed, targetSpeed, dt)
    else
        targetSpeed = throttle * 100 - gravityMod
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
end

--[[ function drawPoints(plane, image)
    love.graphics.push()
    local rotation = math.rad(plane.angle - 90)
    love.graphics.rotate(rotation)

    love.graphics.setColor(1, 0, 0)
    love.graphics.points(getPoints(plane, image))
    love.graphics.setColor(1, 1, 1)

    love.graphics.pop()
end ]]

--[[ function getPoints(plane, image)
    point1 = {
        x = plane.x - image:getWidth() / 10,
        y = plane.y - image:getHeight() / 10
    }
    point2 = {
        x = plane.x + image:getWidth() / 10,
        y = plane.y - image:getHeight() / 10
    }
    point3 = {
        x = plane.x - image:getWidth() / 10,
        y = plane.y + image:getHeight() / 10
    }
    point4 = {
        x = plane.x + image:getWidth() / 10,
        y = plane.y + image:getHeight() / 10
    }

    return point1.x, point1.y, point2.x, point2.y, point3.x, point3.y, point4.x, point4.y
end ]]

return plane
