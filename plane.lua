imageSide = love.graphics.newImage("resources/images/plane_side.png")
imageTop = love.graphics.newImage("resources/images/plane_top.png")
imageBottom = love.graphics.newImage("resources/images/plane_bottom.png")

local plane = {}

local flipStates = {'none', 'flipped', 'flipping', 'flippingBack'}

function plane.init(x, y, throttle)
    plane.x = x
    plane.y = y
    plane.stick = 0
    plane.angle = 90
    plane.throttle = throttle
    plane.speed = 100

    plane.flipState = 'none'
    plane.flipCooldown = 0.5
    plane.flipAnimationTimer = 0.2
end

function plane.draw()
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
        plane.startFlip()
    end
end

function plane.update(dt)
    updateTimers(dt)
    plane.updateFlip()

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

    if math.abs(plane.angle) >= 360 then
        plane.angle = 0
    end

    -- Calculate top speed

    -- Calculate angle?

    delta = dt * plane.speed
    deltaX = math.cos(math.rad(plane.angle - 90)) * delta
    deltaY = math.sin(math.rad(plane.angle - 90)) * delta

    plane.x = plane.x + deltaX
    plane.y = plane.y + deltaY
end

function plane.startFlip()
    plane.flipAnimationTimer = 0

    if plane.flipState == 'none' then
        plane.flipState = 'flipping'
    elseif plane.flipState == 'flipped' then
        plane.flipState = 'flippingBack'
    end
end

function plane.updateFlip()
    if plane.flipState == 'none' or plane.flipState == 'flipped' then
        return
    end

    if plane.flipAnimationTimer >= 0.2 then
        if plane.flipState == 'flipping' then
            plane.flipState = 'flipped'
        else
            plane.flipState = 'none'
        end
    end

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

    return newAngle
end

function lerp(a, b, t)
    return a * (1 - t) + b * t
end

function updateTimers(dt)
    if plane.flipCooldown <= 0.5 then
        plane.flipCooldown = plane.flipCooldown + dt
    end

    if plane.flipAnimationTimer <= 0.2 then
        plane.flipAnimationTimer = plane.flipAnimationTimer + dt
    end
end

return plane
