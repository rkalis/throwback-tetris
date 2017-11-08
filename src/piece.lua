local kalis = require "lib.kalis"
local Piece = {}

function Piece:new(board, coordinates, colour)
    local obj = {
        board = board,
        coordinates = coordinates,
        colour = colour
    }
    print(coordinates[1].x, coordinates[1].y)
    print(colour[1], colour[2], colour[3])
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Piece:draw()
    for _, coordinate in ipairs(self.coordinates) do
        local cell = self.board:getCell(coordinate.x, coordinate.y)
        cell:draw(self.colour)
    end
end

return Piece
