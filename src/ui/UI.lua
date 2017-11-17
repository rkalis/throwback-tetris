local Label = require "src.ui.label"
local Button = require "src.ui.button"
local UI = {}

function UI:new(start_x, start_y, end_x, end_y)
    width = end_x - start_x
    height = end_y - start_y
    local obj = {
        labels = {
            time  = Label:new(start_x + width * 1/5 - 20, start_y + height / 8, "Time: ")
        },
        buttons = {
        }
    }

    setmetatable(obj, self)
    self.__index = self
    return obj
end

function UI:draw(time)
    self.labels.time:draw(time)
    for _, button in pairs(self.buttons) do
        button:draw()
    end
end

return UI
