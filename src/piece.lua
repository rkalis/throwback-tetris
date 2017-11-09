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

function Piece:willCollide(other, direction)
    for _, coord in ipairs(self.coordinates) do
        for _, other_coord in ipairs(other.coordinates) do
            if coord[direction] + 1 == other_coord[direction]
            or coord[direction] - 1 == other_coord[direction] then
                return true
            end
        end
    end
    return false
end

function Piece:step()
    for i = 1, #self.coordinates do
        self.coordinates[i].y = self.coordinates[i].y + 1
    end
end

function Piece:draw()
    for _, coordinate in ipairs(self.coordinates) do
        local cell = self.board:getCell(coordinate.x, coordinate.y)
        cell:draw(self.colour)
    end
end

return Piece
