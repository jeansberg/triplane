local controls = {}

function controls.update(dt, setThrottle)
    if love.keyboard.isDown("up") then
        setThrottle(dt*0.1)
    elseif love.keyboard.isDown("down") then
        setThrottle(-dt*0.1)
    end
  end  

return controls