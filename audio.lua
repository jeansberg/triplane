local constants = require("constants")

local audio = {}

local enginePath = "resources/audio/engine2.wav"
local engineLowPath = "resources/audio/enginelow.wav"
local engineTurnoffPath = "resources/audio/engineturnoff.wav"
local engineTurnonPath = "resources/audio/engineturnon.wav"
local windPath = "resources/audio/wind.wav"
local explosionPath = "resources/audio/explosion.wav"

local function getSource(path)
    return love.audio.newSource(path, "static")
end

function audio.createEngine()
    local src = getSource(enginePath)
    src:setLooping(true)
    return src
end

function audio.createLow()
    local src = getSource(engineLowPath)
    src:setLooping(true)
    return src
end

function audio.createEngineTurnOff()
    return getSource(engineTurnoffPath)
end

function audio.createEngineTurnOn()
    return getSource(engineTurnonPath)
end

function audio.createWind()
    local src = getSource(windPath)
    src:setLooping(true)
    return src
end

function audio.createExplosion()
    local src = getSource(explosionPath)
    src:setVolume(0.5)
    return src
end

--- Loops an engine sound with pitch depending on throttle
function audio.playEngine(sounds, throttle)
    local pitch = 0.5 + throttle / 3

    sounds.engine:setPitch(pitch)
    sounds.engineLow:setPitch(pitch * 2.5)

    sounds.engine:setVolume(throttle + 0.1)
    sounds.engineLow:setVolume(1 - throttle)
    if sounds.engineTurnon:tell("seconds") <= 0.7 then
        sounds.engine:play()
        sounds.engineLow:play()
    end
end

--- Loops a wind sound with pitch and volume depending on speed
function audio.playWind(wind, speed)
    local pitch = math.max(0.1, speed / constants.windThreshold)
    local volume = math.max(0.1, speed / constants.windThreshold - 1)

    wind:setPitch(pitch)
    wind:setVolume(volume)
    wind:play()
end

function audio.playTurnoff(sounds)
    sounds.engineTurnoff:play()
    sounds.engineLow:stop()
    sounds.engine:stop()
end

function audio.playTurnon(sounds)
    sounds.engine:setVolume(0.5)
    sounds.engineTurnon:play()
end

function audio.playExplosion(explosion)
    explosion:play()
end

function audio.killSound(sounds)
    sounds.engineLow:stop()
    sounds.engine:stop()
    sounds.engineTurnoff:stop()
    sounds.engineTurnon:stop()
    sounds.wind:stop()
end

return audio
