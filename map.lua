local map = {}
map.image = love.graphics.newImage("resources/images/background.png")
map.image2 = love.graphics.newImage("resources/images/background2.png")

map.isMap = true

function map:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function map.draw(self)
    love.graphics.draw(self.image)
    love.graphics.draw(self.image2, 1024)
end

function map.getCollisionBox()
    local x = 0
    local y = 635
    local width = 2048
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
