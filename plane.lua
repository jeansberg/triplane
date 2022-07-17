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

function plane:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function plane.createPlane(x, y, throttle)
    local newPlane = plane:new { x = x,
        y = y,
        engineOn = 1,
        stick = 0,
        angle = 90,
        throttle = throttle,
        speed = 100,
        destroyed = false,
        grounded = false,
        lastXSpeed = 0,
        lastYSpeed = 0,

        flipState = flipState.NONE,
        flipCooldown = flipCooldownMax,
        flipAnimationTimer = flipAnimationTimerMax,

        engineCooldown = engineCooldownMax,

        smoke = particle.createSmoke(),
        speedlines = particle.createSpeedlines(),
        explosion = { particleSystems = {} },

        sounds = {
            engine = audio.createEngine(),
            engineLow = audio.createLow(),
            engineTurnoff = audio.createEngineTurnOff(),
            engineTurnon = audio.createEngineTurnOn(),
            wind = audio.createWind(),
            explosion = audio.createExplosion()
        }
    }

    return newPlane
end

function plane.draw(self)
    local image
    if self.destroyed then
        image = imageWreck
    elseif self.flipState == flipState.FLIPPING then
        image = imageTop
    elseif self.flipState == flipState.FLIPPING_BACK then
        image = imageBottom
    else
        image = imageSide
    end

    if self.flipState == flipState.NONE then
        love.graphics.draw(image, self.x, self.y, math.rad(self.angle - 90), 0.2, 0.2, image:getWidth() / 2,
            image:getHeight() / 2)
    else
        love.graphics.draw(image, self.x, self.y, math.rad(self.angle - 90), 0.2, -0.2, image:getWidth() / 2,
            image:getHeight() / 2)
    end

    for _, p in pairs(self.explosion.particleSystems) do
        love.graphics.draw(p, 0, 0)
    end

    if self.destroyed then
        return
    end

    love.graphics.draw(self.smoke, 0, 0)
    love.graphics.draw(self.speedlines, 0, 0)
end

function plane.toggleEngine(self)
    if self.destroyed then
        return
    end

    self.engineOn = not self.engineOn
    if not self.engineOn then
        audio.playTurnoff(self.sounds)
        self.throttle = 0.5
    else
        audio.playTurnon(self.sounds)
    end
end

function love.keypressed(key)
    if key == controlKey.FLIP and Player.flipCooldown >= flipCooldownMax then
        animation.startFlip(Player)
    elseif key == 'r' then
        Player:destroy()
        Player = plane.createPlane(20, 400, 1)
    elseif key == 'e' and Player.engineCooldown > engineCooldownMax then
        Player.engineCooldown = 0
        Player:toggleEngine()
    elseif key == 'x' then
        Player:destroy()
    end
end

function plane.updateParticles(self, dt)
    particle.updateSmoke(self.smoke, self.engineOn and self.throttle + 0.1 or 0, self.x, self.y, self.angle, dt)
    particle.updateSpeedlines(self.speedlines, self.x, self.y, self.angle, self.speed, dt)
    particle.updateExplosions(self.explosion, dt)
end

local function getSpeed(speed, throttle, engineOn, angle, dt)
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

local function getAngle(angle, stick, speed, dt)
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

function plane.update(p, dt)
    p:updateParticles(dt)

    if p.engineOn then
        audio.playEngine(p.sounds, p.throttle)

        if p == Player then
            if love.keyboard.isDown(controlKey.UP) then
                p.throttle = math.min(2, p.throttle + dt)
            elseif love.keyboard.isDown(controlKey.DOWN) then
                p.throttle = math.max(p.throttle - dt, 0)
            end
        end
    end

    if not p.destroyed then
        audio.playWind(p.sounds.wind, p.speed)
        updateTimers(p, dt)
        animation.updateFlip(p)

        if p == Player then
            if love.keyboard.isDown(controlKey.LEFT) then
                p.stick = p.flipState == flipState.FLIPPED and stickState.FORWARD or stickState.BACK
            elseif love.keyboard.isDown(controlKey.RIGHT) then
                p.stick = p.flipState == flipState.FLIPPED and stickState.BACK or stickState.FORWARD
            else
                p.stick = stickState.NEUTRAL
            end
        end
    end

    p.speed = getSpeed(p.speed, p.throttle, p.engineOn, p.angle, dt)

    if p.grounded then
        p.y = 635
        p.angle = mathFunc.lerp(p.angle, 90, dt)

        p.x = p.x + dt * p.lastXSpeed * 0.75

        p.lastXSpeed = mathFunc.lerp(p.lastXSpeed, 0, dt)
    else
        p.angle = getAngle(p.angle, p.stick, p.speed, dt)

        local speed = p.speed
        local xSpeed = math.cos(math.rad(p.angle - 90)) * speed
        local ySpeed = math.sin(math.rad(p.angle - 90)) * speed

        p.lastXSpeed = xSpeed
        p.lastYSpeed = ySpeed

        p.x = p.x + xSpeed * dt
        p.y = p.y + ySpeed * dt
    end
end

function updateTimers(p, dt)
    if p.flipCooldown <= flipCooldownMax then
        p.flipCooldown = p.flipCooldown + dt
    end

    if p.flipAnimationTimer <= flipAnimationTimerMax then
        p.flipAnimationTimer = p.flipAnimationTimer + dt
    end

    if p.engineCooldown <= engineCooldownMax then
        p.engineCooldown = p.engineCooldown + dt
    end
end

function plane.getCollisionBox(self)
    local x = self.x
    local y = self.y
    local width = 280 / 5
    local height = 142 / 5

    return {
        x = x - width,
        y = y - height,
        width = width,
        height = height
    }
end

function plane.destroy(self)
    self.grounded = true
    self.destroyed = true
    self.engineOn = false

    audio.playExplosion(self.sounds.explosion)
    audio.killSound(self.sounds)
    self.explosion = particle.createExplosionSystems(self.x, self.y, self.lastXSpeed)
end

function plane.handleCollision(self, object)
    if self.destroyed then
        return
    end

    if object.isMap then
        self:destroy(p)
    end
end

return plane
