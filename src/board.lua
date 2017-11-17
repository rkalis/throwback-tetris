local Cell = require "src.cell"
local Piece = require "src.piece"
local kalis = require "lib.kalis"

local Board = {}

local coordinatesList = {
    {
        {x = 3, y = 4},
        {x = 4, y = 4},
        {x = 5, y = 4},
        {x = 6, y = 4}
    },
    {
        {x = 3, y = 4},
        {x = 4, y = 4},
        {x = 5, y = 4},
        {x = 3, y = 5}
    },
    {
        {x = 3, y = 4},
        {x = 4, y = 4},
        {x = 5, y = 4},
        {x = 5, y = 5}
    },
    {
        {x = 3, y = 4},
        {x = 4, y = 4},
        {x = 5, y = 4},
        {x = 4, y = 5}
    },
    {
        {x = 4, y = 4},
        {x = 5, y = 4},
        {x = 3, y = 5},
        {x = 4, y = 5}
    },
    {
        {x = 3, y = 4},
        {x = 4, y = 4},
        {x = 4, y = 5},
        {x = 5, y = 5}
    },
    {
        {x = 4, y = 4},
        {x = 5, y = 4},
        {x = 4, y = 5},
        {x = 5, y = 5}
    }
}

local coloursList = {
    {22, 160, 133},
    {39, 174, 96},
    {44, 62, 80},
    {243, 156, 18},
    {231, 76, 60},
    {155, 89, 182},
    {251, 105, 100},
    {71, 46, 50},
    {189, 187, 153},
    {119, 117, 169},
    {115, 168, 87}
}

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

    -- Set cells
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

function Board:newPiece()
    local coordinates = kalis.copy(
        coordinatesList[math.random(#coordinatesList)])
    table.insert(
        self.pieces,
        Piece:new(
            self,
            coordinates,
            coloursList[math.random(#coloursList)]
        )
    )
end

function Board:getActivePiece()
    return self.pieces[#self.pieces]
end

-- Iterator over all cells in board
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

-- Returns cell found at specified board coordinates or nil
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

-- Returns cell found at the specified mouse coordinates
function Board:mouseToCell(mouse_x, mouse_y)
    return self:getCell(self:mouseToBoard(mouse_x, mouse_y))
end

-- Returns board coordinates for the specified mouse coordinates
function Board:mouseToBoard(mouse_x, mouse_y)
    if mouse_y >= self.width * self.cell_size then return nil end
    local board_y = math.floor(mouse_y / self.cell_size)
    local board_x = math.floor(mouse_x / self.cell_size)
    return board_x, board_y
end

function Board:move(direction, side)
    local piece = self:getActivePiece()
    if piece then
        if not piece:willCollideAny(self.bounds, direction, side) and
           not piece:willCollideAny(self.pieces, direction, side) then
            piece:move(direction, side)
        end
    end
end

function Board:step(direction, side)
    local has_moved = false
    local piece = self:getActivePiece()
    if piece then
        if not piece:willCollideAny(self.bounds, direction, side) and
           not piece:willCollideAny(self.pieces, direction, side) then
            piece:move(direction, side)
            has_moved = true
        end
    end

    if not has_moved then
        self:checkLines()
        self:newPiece()
    end
end

function Board:skip(which)
    local piece = which or self:getActivePiece()
    if piece then
        while not piece:willCollide(self.bounds.bottom, 'y', 1) and
              not piece:willCollideAny(self.pieces, 'y', 1) do
            piece:move('y', 1)
        end
    end
    if not which then
        self:checkLines()
        self:newPiece()
    end
end


function Board:getFilledCoordinates()
    local filled_coordinates = {}
    for _, piece in ipairs(self.pieces) do
        for _, coord in ipairs(piece.coordinates) do
            table.insert(filled_coordinates, coord)
        end
    end
    return filled_coordinates
end

function Board:checkLines()
    local finished_lines = {}
    local filled_coordinates = self:getFilledCoordinates()

    for y = 0, self.height - 1 do
        local has_empty_cells = false
        for x = 0, self.width - 1 do
            if not kalis.contains(filled_coordinates, {x = x, y = y}) then
                has_empty_cells = true
                break
            end
        end
        if not has_empty_cells then
            print(y)
            table.insert(finished_lines, y)
        end
    end

    for _, y in ipairs(finished_lines) do
        for x = 0, self.width - 1 do
            for i = #self.pieces, 1, -1 do
                print(i)
                local piece = self.pieces[i]
                piece:removeCoordinate(x, y)
                if #piece.coordinates == 0 then
                    table.remove(self.pieces, i)
                end
            end
        end
    end
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
