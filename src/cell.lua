local class = require "lib.middleclass"


--- @class Cell
--- @field new fun(self: Cell, x: integer, y: integer, size: integer)
local Cell = class("Cell")

--- @param x integer @ The x coordinate of the cell
--- @param y integer @ The y coordinate of the cell
--- @param size integer @ The size of the cell in pixels
function Cell:initialize(x, y, size)
    self.x = x
    self.y = y
    self.size = size
end

--- Checks if two cells occupy the same coordinates
--- @param other Cell @ The other cell
--- @return boolean @ true if their coordinates match, false if not
function Cell:equals(other)
    return self.x == other.x and self.y == other.y
end

--- Draws the cell (optionally coloured)
--- @param colour table @ The colour to draw the cell with (default none)
function Cell:draw(colour)
    if colour then
        love.graphics.setColor(colour)
        love.graphics.rectangle("fill", self.x, self.y, self.size, self.size)
    end

    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.rectangle("line", self.x, self.y, self.size, self.size)
    love.graphics.setColor(1, 1, 1)
end

return Cell
