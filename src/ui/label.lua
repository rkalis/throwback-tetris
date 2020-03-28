local class = require "lib.middleclass"


--- @class Label
--- @field new fun(self: Label, x: integer, y: integer, text: string)
local Label = class("Label")

--- @param x integer @ The x coordinate of the label
--- @param y integer @ The y coordinate of the label
--- @param text string @ The text to be displayed on the label
function Label:initialize(x, y, text)
    self.x = x
    self.y = y
    self.text = text
end

--- Draws the label with potentially additional text
--- @param value string @ Additional text to be displayed beside the label text
function Label:draw(value)
    local val = value or ""
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.text .. val, self.x, self.y)
    love.graphics.setColor(1, 1, 1)
end

return Label
