constants = require("constants")

local audio = {}

local engineSound = love.audio.newSource("resources/audio/engine2.wav", "static")
local engineLowSound = love.audio.newSource("resources/audio/enginelow.wav", "static")
local engineTurnoffSound = love.audio.newSource("resources/audio/engineturnoff.wav", "static")
local engineTurnonSound = love.audio.newSource("resources/audio/engineturnon.wav", "static")
local windSound = love.audio.newSource("resources/audio/wind.wav", "static")
local explosionSound = love.audio.newSource("resources/audio/explosion.wav", "static")

engineSound:setLooping(true)
engineLowSound:setLooping(true)
windSound:setLooping(true)

local engineTurnOnDuration = engineTurnonSound:getDuration("samples")
local windThreshold = 200

--- Loops an engine sound with pitch depending on throttle
function audio.playEngine(throttle)
    local pitch = 0.5 + throttle / 3

    engineSound:setPitch(pitch)
    engineLowSound:setPitch(pitch * 2.5)

    engineSound:setVolume(throttle + 0.1)
    engineLowSound:setVolume(1 - throttle)
    if engineTurnonSound:tell("samples") <= engineTurnOnDuration * 0.8 then
        engineSound:play()
        engineLowSound:play()
    end
end

--- Loops a wind sound with pitch and volume depending on speed
function audio.playWind(speed)
    local pitch = math.max(0.1, speed / constants.windThreshold)
    local volume = math.max(0.1, speed / constants.windThreshold - 1)

    windSound:setPitch(pitch)
    windSound:setVolume(volume)
    windSound:play()
end

function audio.playTurnoff()
    engineTurnoffSound:play()
    engineLowSound:stop()
    engineSound:stop()
end

function audio.playTurnon()
    engineSound:setVolume(0.5)
    engineTurnonSound:play()
end

function audio.playExplosion()
    explosionSound:setVolume(0.5)
    explosionSound:play()
end

function audio.killSound()
    engineLowSound:stop()
    engineSound:stop()
    engineTurnoffSound:stop()
    engineTurnonSound:stop()
    windSound:stop()
end

return audio
