local kalis = require "lib.kalis"
local Piece = {}

function Piece:new(board, coordinates, colour)
    local obj = {
        board = board,
        coordinates = coordinates,
        colour = colour
    }
    print(coordinates[1].x, coordinates[1].y)
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Piece:willCollide(other, direction, side)
    if self == other then return false end
    for _, coord in ipairs(self.coordinates) do
        local next_coord = kalis.copy(coord)
        next_coord[direction] = next_coord[direction] + side
        for _, other_coord in ipairs(other.coordinates) do
            if kalis.equals(next_coord, other_coord) then
                return true
            end
        end
    end
    return false
end

function Piece:willCollideAny(others, direction, side)
    for _, other in ipairs(others) do
        if self:willCollide(other, direction, side) then return true end
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
