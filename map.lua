local map = {}
map.image = love.graphics.newImage("resources/images/background.png")


function map.draw()
    love.graphics.draw(map.image)
end

return map