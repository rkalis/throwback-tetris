local Cell = require "src.cell"
local Piece = require "src.piece"
local kalis = require "lib.kalis"
local Board = {}


-- Initialise the board
-- @Arguments
--  width          - The width of the board in cells
--  height         - The height of the board in cells
--  cell_size      - The size of a single cell on the board
-- @Returns
--  the initialised board object
function Board:new(width, height, cell_size)
    local obj = {
        cell_size = cell_size,
        width = width,
        height = height,
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
        },
        pieces = {},
        score = 0,
        back_to_back = 0,
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

    obj.next_piece = Piece.generate(obj)

    setmetatable(obj, self)
    self.__index = self
    return obj
end

-- Puts next_piece into the board
-- Generates a new random piece for next_piece
function Board:newPiece()
    table.insert(self.pieces, self.next_piece)
    self.next_piece = Piece.generate(self)
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

    if not has_moved then self:onPieceLanded() end
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

-- Called after a piece has landed
-- Clears and scores any filled lines, and generates the next piece
function Board:onPieceLanded()
    local filled_lines = self:getFilledLines()
    self:clearLines(filled_lines)
    self:scoreLines(#filled_lines)
    self:newPiece()
end

-- @Returns
--  all lines that are completely filled
function Board:getFilledLines()
    local occupied_coords = self:getOccupiedCoords()
    local filled_lines = {}

    -- Loop through all cells in all lines to check if they're occupied
    -- Add fully occupied lines to filled_lines
    for y = 0, self.height - 1 do
        local has_empty_cells = false
        for x = 0, self.width - 1 do
            if not kalis.contains(occupied_coords, {x = x, y = y}) then
                has_empty_cells = true
                break
            end
        end
        if not has_empty_cells then
            table.insert(filled_lines, y)
        end
    end
    return filled_lines
end

-- Clear any provided line numbers
-- @Arguments
--  filled_lines - A list of line numbers to be cleared
function Board:clearLines(filled_lines)
    -- Try to remove all coordinates in finished lines from all pieces on the board
    -- If pieces have no coordinates left, they're cleaned
    for _, y in ipairs(filled_lines) do
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

    -- Advance the remaining pieces to account for the removed lines
    for _, piece in ipairs(self.pieces) do
        for i, coord in ipairs(piece.coordinates) do
            for _, line_number in ipairs(filled_lines) do
                if coord.y < line_number then
                    piece.coordinates[i].y = coord.y + 1
                end
            end
        end
    end
end

-- Updates board score according to the number of lines cleared
-- @Arguments
--  num_lines - The number of lines cleared
function Board:scoreLines(num_lines)
    if (num_lines <= 0) then return end

    -- Update back-to-back tetris count
    if num_lines >= 4 then
        self.back_to_back = self.back_to_back + 1
    else
        self.back_to_back = 0
    end

    -- Score 100 per line, plus 100 per back-to-back tetris
    local added_score = num_lines * 100 + self.back_to_back * 100
    self.score = self.score + added_score
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
