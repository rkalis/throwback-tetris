local Label = {}

-- Initialise a label
-- @Arguments
--  x    - The x coordinate of the label
--  y    - The y coordinate of the label
--  text - The text deisplayed on the label
-- @Returns
--  the initialised label object
function Label:new(x, y, text)
    local obj = {
        x = x,
        y = y,
        text = text
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

-- Draws the label, with potentially additional text
-- @Arguments
--  value? - Additional text to be displayed beside the label
function Label:draw(value)
    local val = value or ""
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.text .. val, self.x, self.y)
    love.graphics.setColor(1, 1, 1)
end

return Label
