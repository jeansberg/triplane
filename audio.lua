local audio = {}

engineSound = love.audio.newSource("resources/audio/engine1.wav", "static")
engineSound:setLooping(true)

function audio.playEngine(throttle)
    engineSound:setPitch(throttle)
    engineSound:play()
end

return audio