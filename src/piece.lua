local kalis = require "lib.kalis"
local Piece = {}


-- The rounding functions to use when rotating depending on what step (1-4)
-- the piece is in the rotation process
local rounding_functions = {
    { x = math.floor, y = math.floor },
    { x = math.ceil, y = math.floor },
    { x = math.ceil, y = math.ceil },
    { x = math.floor, y = math.ceil }
}

-- Initialise a piece
-- @Arguments
--  board       - The board this piece belongs to
--  coordinates - { x, y } The coordinates of this piece
--  colour      - The colour of this piece
-- @Returns
--  the initialised piece object
function Piece:new(board, coordinates, colour)
    local obj = {
        board = board,
        coordinates = coordinates,
        colour = colour,
        rounding_step = 1
    }
    print(coordinates[1].x, coordinates[1].y)
    setmetatable(obj, self)
    self.__index = self
    return obj
end

-- Check whether two pieces have overlapping coordinates
-- @Arguments
--  o1 - The one piece
--  o2 - The other piece
-- @Returns
--  true if o1 and o2 have overlapping coordinates, false if not
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

-- Check if the piece will collide with other in the next step
-- @Arguments
--  other - The collidable other object
--  axis  - The axis of the next step
--  delta - The change of the next step
-- @Returns
--  true if self will collide with other in the next step, false if not
function Piece:willCollide(other, axis, delta)
    if self == other then return false end
    for _, coord in ipairs(self.coordinates) do
        local next_coord = kalis.copy(coord)
        next_coord[axis] = next_coord[axis] + delta
        for _, other_coord in ipairs(other.coordinates) do
            if kalis.equals(next_coord, other_coord) then
                return true
            end
        end
    end
    return false
end

-- Check if the piece will collide with any of others in the next step
-- @Arguments
--  others - A list of collidable objects
--  axis   - The axis of the next step
--  delta  - The change of the next step
-- @Returns
--  true if self will collide with any of others in the next step, false if not
function Piece:willCollideAny(others, axis, delta)
    for _, other in pairs(others) do
        if self:willCollide(other, axis, delta) then return true end
    end
    return false
end

-- Check if the piece can rotate, or if it is blocked from rotating
-- by bounds or other pieces
-- @Returns
--  true if self can rotate, false if not
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

-- Returns the new coordinates of the piece, should it rotate. Calculates the pieces
-- midpoint and rotates around it, using the correct rounding function.
function Piece:getRotatedCoordinates()
    local new_coordinates = {}
    local mid = self:getMidpoint()
    for i = 1, #self.coordinates do
        local x = self.coordinates[i].x - mid.x
        local y = self.coordinates[i].y - mid.y
        new_coordinates[i] = {
            x = rounding_functions[self.rounding_step].x(-y + mid.x),
            y = rounding_functions[self.rounding_step].y(x + mid.y)
        }
    end
    return new_coordinates
end

-- Updates the pieces coordinates to rotated ones and advances the rounding_step
function Piece:rotate()
    self.coordinates = self:getRotatedCoordinates()
    self.rounding_step = self.rounding_step % 4 + 1
end

-- Calculates the midpoint of the piece
-- @Returns
--  { x, y } board coordinates of the midpoint
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

-- Remove a coordinate from a piece if it exists on the piece
function Piece:removeCoordinate(x, y)
    for i, coord in ipairs(self.coordinates) do
        if coord.x == x and coord.y == y then
            table.remove(self.coordinates, i)
        end
    end
end

-- Move the piece by a delta along an axis
-- @Arguments
--  axis  - 'x' or 'y'
--  delta - How large the move is and in which direction along the axis
function Piece:move(axis, delta)
    for i = 1, #self.coordinates do
        self.coordinates[i][axis] = self.coordinates[i][axis] + delta
    end
end

function Piece:draw()
    for _, coordinate in ipairs(self.coordinates) do
        local cell = self.board:getCell(coordinate.x, coordinate.y)
        cell:draw(self.colour)
    end
end

return Piece
