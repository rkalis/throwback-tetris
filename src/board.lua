local Cell = require "src.cell"
local kalis = require "lib.kalis"

local Board = {}

function Board:new(width, height, cell_size, start_of_board)
    local obj = {
        start_of_board = start_of_board,
        cell_size = cell_size,
        width = width,
        height = height
    }

    -- Set cells
    for i = 0, height - 1 do
        obj[i] = {}
        for j = 0, width - 1 do
            obj[i][j] = Cell:new(j * cell_size, i * cell_size + start_of_board,
                                 cell_size)
        end
    end

    setmetatable(obj, self)
    self.__index = self
    return obj
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
    if mouse_y < self.start_of_board then return nil end
    local board_y = math.floor((mouse_y - self.start_of_board) / self.cell_size)
    local board_x = math.floor(mouse_x / self.cell_size)
    return board_x, board_y
end

function Board:draw()
    for cell in self:cells() do
        cell:draw()
    end
end

return Board
