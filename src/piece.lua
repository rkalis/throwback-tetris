local kalis = require "lib.kalis"
local class = require "lib.middleclass"


--- @class Piece
--- @field new fun(self: Piece, board: Board, coordinates: table, colour: table)
local Piece = class("Piece")
Piece.bag = {}

-- The rounding functions to use when rotating depending on what step (1-4)
-- the piece is in the rotation process
local rounding_functions = {
    { x = math.floor, y = math.floor },
    { x = math.ceil, y = math.floor },
    { x = math.ceil, y = math.ceil },
    { x = math.floor, y = math.ceil }
}

-- Colours and starting coordinates of the different predefined pieces
local piecePrototypes = {
    -- xxxx (cyan)
    {
        coordinates = {{ x = 3, y = 1 }, { x = 4, y = 1 }, { x = 5, y = 1 }, { x = 6, y = 1 }},
        colour = {0.41, 1.00, 0.93}
    },
    --   x (orange)
    -- xxx
    {
        coordinates = {{ x = 5, y = 0 }, { x = 3, y = 1 }, { x = 4, y = 1 }, { x = 5, y = 1 }},
        colour = {0.99, 0.59, 0.13}
    },
    -- x   (blue)
    -- xxx
    {
        coordinates = {{ x = 3, y = 0 }, { x = 3, y = 1 }, { x = 4, y = 1 }, { x = 5, y = 1 }},
        colour = {0.03, 0.39, 1.00}
    },
    --  x  (purple)
    -- xxx
    {
        coordinates = {{ x = 4, y = 0 }, { x = 3, y = 1 }, { x = 4, y = 1 }, { x = 5, y = 1 }},
        colour = {0.86, 0.20, 0.97}
    },
    --  xx (green)
    -- xx
    {
        coordinates = {{ x = 4, y = 0 }, { x = 5, y = 0 }, { x = 3, y = 1 }, { x = 4, y = 1 }},
        colour = {0.33, 0.98, 0.28}
    },
    -- xx  (red)
    --  xx
    {
        coordinates = {{ x = 3, y = 0 }, { x = 4, y = 0 }, { x = 4, y = 1 }, { x = 5, y = 1 }},
        colour = {1.00, 0.27, 0.23}
    },
    --  xx (yellow)
    --  xx
    {
        coordinates = {{ x = 4, y = 0 }, { x = 5, y = 0 }, { x = 4, y = 1 }, { x = 5, y = 1 }},
        colour = {1.00, 0.93, 0.41}
    }
}

--- @param board Board @ The board this piece belongs to
--- @param coordinates table @ { x, y } The coordinates of this piece
--- @param colour table @ The colour of this piece
function Piece:initialize(board, coordinates, colour)
    self.board = board
    self.coordinates = coordinates
    self.colour = colour
    self.rounding_step = 1
end

--- Generate a new piece for board `board` using bag-based RNG selection.
--- @param board Board @ The board the generated piece belongs to
--- @return Piece @ The newly generated piece
function Piece.generate(board)
    if #Piece.bag == 0 then Piece.bag = kalis.copy(piecePrototypes) end
    local prototype = table.remove(Piece.bag, math.random(#Piece.bag))
    return Piece:new(board, prototype.coordinates, prototype.colour)
end

--- Checck whether two pieces have overlapping coordinates
--- @param o1 Piece @ The one piece
--- @param o2 Piece @ The other piece
--- @return boolean @ true if `o1` and `o2` have overlapping coordinates, false if not
local function areColliding(o1, o2)
    if o1 == o2 then return false end
    for _, coord in ipairs(o1.coordinates) do
        for _, other_coord in ipairs(o2.coordinates) do
            if kalis.deep_equals(coord, other_coord, true) then
                return true
            end
        end
    end
    return false
end

--- @alias AxisEnum string | "'x'" | "'y'"

--- Check if the piece will collide with `other` in the next step
--- @param other Piece|table @ The collidable other object
--- @param axis AxisEnum @ The axis of the next step
--- @param delta integer @ The change of the next step along `axis`
--- @return boolean @ true if `self` will collide with `other`, false if not
function Piece:willCollide(other, axis, delta)
    if self == other then return false end
    for _, coord in ipairs(self.coordinates) do
        local next_coord = kalis.copy(coord)
        next_coord[axis] = next_coord[axis] + delta
        for _, other_coord in ipairs(other.coordinates) do
            if kalis.deep_equals(next_coord, other_coord) then
                return true
            end
        end
    end
    return false
end

--- Check if the piece will collide with any of `others` in the next step
--- @param others (Piece|table)[] @ A list of collidable objects
--- @param axis AxisEnum @ The axis of the next step
--- @param delta integer @ The change of the next step along `axis`
--- @return boolean true if `self` will collide with any of `others` false if not
function Piece:willCollideAny(others, axis, delta)
    for _, other in pairs(others) do
        if self:willCollide(other, axis, delta) then return true end
    end
    return false
end

--- Check if the piece can rotate, or if it is blocked from rotating.
--- TODO: Implement Tetris Guidelines for rotation
--- @return boolean @ true if `self` can rotate, false if not
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

--- Returns the new coordinates of the piece, should it rotate. Calculates the pieces
--- midpoint and rotates around it, using the correct rounding function.
--- @return table @ Rotated coordinates
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

--- Updates the pieces coordinates to rotated ones and advances the rounding_step
function Piece:rotate()
    self.coordinates = self:getRotatedCoordinates()
    self.rounding_step = self.rounding_step % 4 + 1
end

--- Calculates the midpoint of the piece. TODO: Check if conform with Tetris Guidelines
--- @return table @ Board coordinates of the midpoint
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

--- Remove a coordinate from a piece if it exists on the piece.
--- @param x integer @ The x coordinate to remove
--- @param y integer @ The y coordinate to remove
function Piece:removeCoordinate(x, y)
    for i, coord in ipairs(self.coordinates) do
        if coord.x == x and coord.y == y then
            table.remove(self.coordinates, i)
        end
    end
end

--- Move the piece by a delta along an axis
--- @param axis AxisEnum @ The axis of the move
--- @param delta integer @ The size and direction of the move
function Piece:move(axis, delta)
    for i = 1, #self.coordinates do
        self.coordinates[i][axis] = self.coordinates[i][axis] + delta
    end
end

--- Draw the piece
function Piece:draw()
    for _, coordinate in ipairs(self.coordinates) do
        local cell = self.board:getCell(coordinate.x, coordinate.y)
        cell:draw(self.colour)
    end
end

return Piece
