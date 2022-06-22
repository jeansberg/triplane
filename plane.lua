image = love.graphics.newImage("resources/images/plane.png")

local plane = {
    x = 0,
    y = 0,
    angle = 90,
    speed = 0
}

function plane.init(x, y, throttle)
    plane.x = x
    plane.y = y
    plane.stick = 0
    plane.angle = 90
    plane.throttle = throttle
    plane.speed = 100
end

function plane.draw()
    love.graphics.draw(image, plane.x, plane.y, math.rad(plane.angle - 90), 0.05, 0.05, image:getWidth() / 2,
        image:getHeight() / 2)
end

function plane.update(dt)
    if love.keyboard.isDown("up") then
        plane.throttle = math.min(2, plane.throttle + dt)
    elseif love.keyboard.isDown("down") then
        plane.throttle = math.max(plane.throttle - dt, 0)
    end

    if love.keyboard.isDown("left") then
        plane.stick = -1
    elseif love.keyboard.isDown("right") then
        plane.stick = 1
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

function getSpeed(speed, throttle, angle, dt)
    gravityMod = math.cos(math.rad(angle)) * 100

    targetSpeed = math.max(0, throttle * 100 - gravityMod)
    return lerp(speed, targetSpeed, dt)
end

function getAngle(angle, stick, speed, dt)
    --[[     if speed < 50 then
        if angle < 180 then
            newAngle = angle + angle * dt
            print(newAngle)
            angle = math.min(180, newAngle)
        else
            angle = math.max(180, angle - angle * dt)
        end
    end ]]

    newAngle = angle

    if stick == 1 then
        newAngle = angle + dt * 100
    elseif stick == -1 then
        newAngle = angle - dt * 100
    else
    end

    print(newAngle)
    return newAngle
end

function lerp(a, b, t)
    return a * (1 - t) + b * t
end

return plane
