constants = require("constants")

local audio = {}

local engineSound = love.audio.newSource("resources/audio/engine2.wav", "static")
engineSound:setLooping(true)

local windSound = love.audio.newSource("resources/audio/wind.wav", "static")
windSound:setLooping(true)

local windThreshold = 200

--- Loops an engine sound with pitch depending on throttle
function audio.playEngine(throttle)
    engineSound:setPitch(throttle)
    engineSound:play()
end

--- Loops a wind sound with pitch and volume depending on speed
function audio.playWind(speed)
    local pitch = math.max(0.1, speed / constants.windThreshold)
    local volume = math.max(0.1, speed / constants.windThreshold - 0.7)

    windSound:setPitch(pitch)
    windSound:setVolume(volume)
    windSound:play()
end

return audio
