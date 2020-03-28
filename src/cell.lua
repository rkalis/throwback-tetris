local Cell = {}


-- Initialise a cell
-- @Arguments
--  x    - The x coord of the cell
--  y    - The y coord dof the cell
--  size - The size of the cell
-- @Returns
--  the initialised cell object
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

-- Checks whether two cells occupy the same coordinates
-- @Arguments
--  other - The other cell
-- @Returns
--  true if their coordinates match, false if not
function Cell:equals(other)
    return self.x == other.x and self.y == other.y
end

-- Draw the cell (optionally coloured)
-- @Arguments
--  colour? - Specifies the colour to draw the cell
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
