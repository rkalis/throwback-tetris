local Cell = require "src.cell"
local Piece = require "src.piece"
local kalis = require "lib.kalis"
local Board = {}


-- Colours and starting coordinates of the different pieces
local piecePrototypes = {
    -- xxxx (cyan)
    {
        coordinates = {{ x = 3, y = 4 }, { x = 4, y = 4 }, { x = 5, y = 4 }, { x = 6, y = 4 }},
        colour = {0.41, 1.00, 0.93}
    },
    -- xxx (orange)
    -- x
    {
        coordinates = {{ x = 3, y = 4 }, { x = 4, y = 4 }, { x = 5, y = 4 }, { x = 3, y = 5 }},
        colour = {0.99, 0.59, 0.13}
    },
    -- xxx (blue)
    --   x
    {
        coordinates = {{ x = 3, y = 4 }, { x = 4, y = 4 }, { x = 5, y = 4 }, { x = 5, y = 5 }},
        colour = {0.03, 0.39, 1.00}
    },
    -- xxx (purple)
    --  x
    {
        coordinates = {{ x = 3, y = 4 }, { x = 4, y = 4 }, { x = 5, y = 4 }, { x = 4, y = 5 }},
        colour = {0.86, 0.20, 0.97}
    },
    --  xx (green)
    -- xx
    {
        coordinates = {{ x = 4, y = 4 }, { x = 5, y = 4 }, { x = 3, y = 5 }, { x = 4, y = 5 }},
        colour = {0.33, 0.98, 0.28}
    },
    -- xx  (red)
    --  xx
    {
        coordinates = {{ x = 3, y = 4 }, { x = 4, y = 4 }, { x = 4, y = 5 }, { x = 5, y = 5 }},
        colour = {1.00, 0.27, 0.23}
    },
    --  xx (yellow)
    --  xx
    {
        coordinates = {{ x = 4, y = 4 }, { x = 5, y = 4 }, { x = 4, y = 5 }, { x = 5, y = 5 }},
        colour = {1.00, 0.93, 0.41}
    }

}

-- Initialise the board
-- @Arguments
--  width          - The width of the board in cells
--  height         - The height of the board in cells
--  cell_size      - The size of a single cell on the board
--  start_of_stats - The coordinates of the sidebar on the board
-- @Returns
--  the initialised board object
function Board:new(width, height, cell_size, start_of_stats)
    local obj = {
        cell_size = cell_size,
        width = width,
        height = height,
        pieces = {},
        bounds = {
            bottom = {
                coordinates = {}
            },
            top = {
                coordinates = {}
            },
            left = {
                coordinates = {}
            },
            right = {
                coordinates = {}
            }
        }
    }

    for i = 0, width - 1 do
        table.insert(obj.bounds.bottom.coordinates, {x = i, y = height})
        table.insert(obj.bounds.top.coordinates, {x = i, y = -1})
    end
    for i = 0, height - 1 do
        table.insert(obj.bounds.left.coordinates, {x = -1, y = i})
        table.insert(obj.bounds.right.coordinates, {x = width, y = i})
    end

    -- Initialise cells
    for i = 0, height - 1 do
        obj[i] = {}
        for j = 0, width - 1 do
            obj[i][j] = Cell:new(j * cell_size, i * cell_size, cell_size)
        end
    end

    setmetatable(obj, self)
    self.__index = self
    return obj
end

-- Generates a new random piece on the board
-- Adds the new piece to the board's list of pieces
function Board:newPiece()
    local prototype = kalis.copy(piecePrototypes[math.random(#piecePrototypes)])
    table.insert(
        self.pieces,
        Piece:new(
            self,
            prototype.coordinates,
            prototype.colour
        )
    )
end

-- Returns the currently active (latest) piece
function Board:getActivePiece()
    return self.pieces[#self.pieces]
end

-- Returns an iterator over all cells in the board
function Board:cells()
    return coroutine.wrap(
        function()
            for _, row in kalis.ipairs(self) do
                for _, cell in kalis.ipairs(row) do
                    coroutine.yield(cell)
                end
            end
        end)
end

-- Returns a cell found at board coordinates (x, y)
function Board:getCell(x, y)
    if not x or not y then return nil end
    if x < 0 or x > self.width or y < 0 or y > self.height then return nil end
    return self[y][x]
end

-- Returns a random cell
function Board:getRandomCell()
    local random_row = self[math.random(0, #self)]
    return random_row[math.random(0, #random_row)]
end

-- Returns a cell found at mouse coordinates (mouse_x, mouse_y)
function Board:mouseToCell(mouse_x, mouse_y)
    return self:getCell(self:mouseToBoard(mouse_x, mouse_y))
end

-- Returns board coordinates (board_x, board_y)
-- for the specified mouse coordinates (mouse_x, mouse_y)
function Board:mouseToBoard(mouse_x, mouse_y)
    if mouse_y >= self.width * self.cell_size then return nil end
    local board_y = math.floor(mouse_y / self.cell_size)
    local board_x = math.floor(mouse_x / self.cell_size)
    return board_x, board_y
end

-- Move the active piece along an axis
-- @Arguments
--  axis  - 'x' or 'y'
--  delta - -1 or 1
function Board:move(axis, delta)
    local piece = self:getActivePiece()
    if piece then
        if not piece:willCollideAny(self.bounds, axis, delta) and
           not piece:willCollideAny(self.pieces, axis, delta) then
            piece:move(axis, delta)
        end
    end
end

-- Advances the active piece one step along the y axis
-- Generates a new piece when the active piece can't advance further
-- @Returns
--  true if the piece moved, false if not
function Board:step()
    local has_moved = false
    local piece = self:getActivePiece()
    if piece then
        if not piece:willCollide(self.bounds.bottom, 'y', 1) and
           not piece:willCollideAny(self.pieces, 'y', 1) then
            piece:move('y', 1)
            has_moved = true
        end
    end

    if not has_moved then
        self:clearLines()
        self:newPiece()
    end

    return has_moved
end

-- Advances the active piece until it can't advance further
function Board:skip()
    local has_moved = true
    local piece = self:getActivePiece()
    while has_moved do has_moved = self:step() end
end

-- Returns all board coordinates that are currenlly occupied by a piece
function Board:getOccupiedCoords()
    local occupied_coords = {}
    for _, piece in ipairs(self.pieces) do
        for _, coord in ipairs(piece.coordinates) do
            table.insert(occupied_coords, coord)
        end
    end
    return occupied_coords
end

-- Clear any fully occupied lines
function Board:clearLines()
    local finished_lines = {}
    local occupied_coords = self:getOccupiedCoords()

    -- Loop through all cells in all lines to check if they're occupied
    -- Add fully occupied lines to finished_lines
    for y = 0, self.height - 1 do
        local has_empty_cells = false
        for x = 0, self.width - 1 do
            if not kalis.contains(occupied_coords, {x = x, y = y}) then
                has_empty_cells = true
                break
            end
        end
        if not has_empty_cells then
            table.insert(finished_lines, y)
        end
    end

    -- Try to remove all coordinates in finished lines from all pieces on the board
    -- If pieces have no coordinates left, they're cleaned
    for _, y in ipairs(finished_lines) do
        for x = 0, self.width - 1 do
            for i = #self.pieces, 1, -1 do
                local piece = self.pieces[i]
                piece:removeCoordinate(x, y)
                if #piece.coordinates == 0 then
                    table.remove(self.pieces, i)
                end
            end
        end
    end
    -- Advance the remaining pieces to account for the removed line
    for _, piece in ipairs(self.pieces) do
        for i, coord in ipairs(piece.coordinates) do
            for _, line_number in ipairs(finished_lines) do
                if coord.y < line_number then
                    piece.coordinates[i].y = coord.y + 1
                end
            end
        end
    end
end

function Board:update(dt)
end

function Board:draw()
    for _, piece in ipairs(self.pieces) do
        piece:draw()
    end
    for cell in self:cells() do
        cell:draw()
    end
end

return Board
