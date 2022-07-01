local map = {}
map.image = love.graphics.newImage("resources/images/background.png")

--- Draws the background
function map.draw()
    love.graphics.draw(map.image)
end

function map.getCollisionBox()
    local x = 0
    local y = 635
    local width = 1024
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
