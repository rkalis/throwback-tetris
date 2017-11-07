local Label = require "src.ui.label"
local Button = require "src.ui.button"
local UI = {}

function UI:new(width, height)
    local obj = {
        labels = {
            time  = Label:new(width * 1/5 - 20, height / 2, "Time: ")
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
