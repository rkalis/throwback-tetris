local Label = require "src.ui.label"
local UI = {}


-- Initialise the UI
-- @Arguments
--  start_x - The x start of the UI section
--  start_y - The y start of the UI section
--  end_x   - The x end of the UI section
--  end_y   - The y end of the UI section
-- @Returns
--  the initialised UI object
function UI:new(start_x, start_y, end_x, end_y)
    width = end_x - start_x
    height = end_y - start_y
    local obj = {
        labels = {
            time  = Label:new(start_x + width * 1/5 - 20, start_y + height / 8, "Time: ")
        }
    }

    setmetatable(obj, self)
    self.__index = self
    return obj
end

-- Draw the UI section with the time filled in
function UI:draw(time)
    self.labels.time:draw(time)
end

return UI
