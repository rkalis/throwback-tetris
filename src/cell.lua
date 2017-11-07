local kalis = require "lib.kalis"
local Cell = {}

function Cell:new(x, y, size)
    local obj = {
        x = x,
        y = y,
        size = size,
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Cell:equals(other)
    return self.x == other.x and self.y == other.y
end

function Cell:drawSprite(sprite)
    love.graphics.draw(sprite, self.x, self.y, 0, self.size / 120)
end

function Cell:draw()
    love.graphics.setColor(100,100,100)
    love.graphics.rectangle("line", self.x, self.y, self.size, self.size)
    love.graphics.setColor(255,255,255)
end

return Cell
