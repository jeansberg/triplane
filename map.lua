local map = {}
map.image = love.graphics.newImage("resources/images/background.png")
map.image2 = love.graphics.newImage("resources/images/background2.png")

map.isMap = true

--- Draws the background
function map.draw()
    love.graphics.draw(map.image)
    love.graphics.draw(map.image2, 1024)
end

function map.getCollisionBox()
    local x = 0
    local y = 635
    local width = 1920
    local height = 768 - 635

    return {
        x = x,
        y = y,
        width = width,
        height = height
    }
end

function map.handleCollision(rect)
end

return map
