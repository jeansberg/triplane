local audio = {}

engineSound = love.audio.newSource("resources/audio/engine2.wav", "static")
engineSound:setLooping(true)

windSound = love.audio.newSource("resources/audio/wind.wav", "static")
windSound:setLooping(true)

function audio.playEngine(throttle)
    engineSound:setPitch(throttle)
    engineSound:play()
end

function audio.playWind(speed)
    if speed < 200 then
        return
    end
    level = speed / 200 - 0.5
    windSound:setPitch(level * 2 + 1)
    windSound:setVolume(level * 3)
    windSound:play()
end

return audio
