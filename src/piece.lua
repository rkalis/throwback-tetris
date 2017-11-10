local kalis = require "lib.kalis"
local Piece = {}

local round_functions = {
    {
        x = math.floor,
        y = math.floor
    },
    {
        x = math.ceil,
        y = math.floor
    },
    {
        x = math.ceil,
        y = math.ceil
    },
    {
        x = math.floor,
        y = math.ceil
    }
}

function Piece:new(board, coordinates, colour)
    local obj = {
        board = board,
        coordinates = coordinates,
        colour = colour,
        round_step = 1
    }
    print(coordinates[1].x, coordinates[1].y)
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function areColliding(o1, o2)
    if o1 == o2 then return false end
    for _, coord in ipairs(o1.coordinates) do
        for _, other_coord in ipairs(o2.coordinates) do
            if kalis.equals(coord, other_coord, true) then
                return true
            end
        end
    end
    return false
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
    for _, other in pairs(others) do
        if self:willCollide(other, direction, side) then return true end
    end
    return false
end

function Piece:canRotate()
    local rotated_coordinates = self:getRotatedCoordinates()
    for _, bound in pairs(self.board.bounds) do
        if areColliding({coordinates = rotated_coordinates}, bound) then
            return false
        end
    end
    for _, piece in ipairs(self.board.pieces) do
        if piece == self then
        elseif areColliding({coordinates = rotated_coordinates}, piece) then
            return false
        end
    end
    return true
end

function Piece:getRotatedCoordinates()
    local new_coordinates = {}
    local mid = self:getMidpoint()
    for i = 1, #self.coordinates do
        local x = self.coordinates[i].x - mid.x
        local y = self.coordinates[i].y - mid.y
        new_coordinates[i] = {
            x = round_functions[self.round_step].x(-y + mid.x),
            y = round_functions[self.round_step].y(x + mid.y)
        }
    end
    return new_coordinates
end

function Piece:rotate()
    self.coordinates = self:getRotatedCoordinates()
    self.round_step = self.round_step % 4 + 1
end

function Piece:getMidpoint()
    local mid_x = 0
    local mid_y = 0
    for _, coordinate in ipairs(self.coordinates) do
        mid_x = mid_x + coordinate.x
        mid_y = mid_y + coordinate.y
    end
    mid_x = mid_x / #self.coordinates
    mid_y = mid_y / #self.coordinates
    return {x = mid_x, y = mid_y}
end

function Piece:move(direction, side)
    for i = 1, #self.coordinates do
        self.coordinates[i][direction] = self.coordinates[i][direction] + side
    end
end

function Piece:draw()
    for _, coordinate in ipairs(self.coordinates) do
        local cell = self.board:getCell(coordinate.x, coordinate.y)
        cell:draw(self.colour)
    end
end

return Piece
