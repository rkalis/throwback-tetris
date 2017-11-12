local kalis = require "lib.kalis"
local Cell = {}

function Cell:new(x, y, size)
    local obj = {
        x = x,
        y = y,
        size = size
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

function Cell:draw(colour, x, y)
    if colour then
        love.graphics.setColor(colour)
        love.graphics.rectangle("fill", self.x, self.y, self.size, self.size)
    end

    love.graphics.setColor(100,100,100)
    love.graphics.rectangle("line", self.x, self.y, self.size, self.size)
    if x and y then
        love.graphics.print(x .. ',' .. y, self.x, self.y)
    end
    love.graphics.setColor(255,255,255)
end

return Cell
