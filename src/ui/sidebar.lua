local Label = require "src.ui.label"
local Cell = require "src.cell"
local kalis = require "lib.kalis"
local Sidebar = {}


-- Initialise the Sidebar
-- @Arguments
--  start_x - The x start of the Sidebar section
--  start_y - The y start of the Sidebar section
--  end_x   - The x end of the Sidebar section
--  end_y   - The y end of the Sidebar section
-- @Returns
--  the initialised Sidebar object
function Sidebar:new(start_x, start_y, end_x, end_y)
    local width = end_x - start_x
    local height = end_y - start_y

    local cell_size = math.floor(width / 10)
    local next_piece_x = start_x + (width / 2) - (2 * cell_size)
    local next_piece_y = start_y + 2 * cell_size

    local obj = {
        labels = {
            time = Label:new(next_piece_x, next_piece_y + cell_size * 4 + 20, "Time: "),
            score = Label:new(next_piece_x, next_piece_y + cell_size * 4 + 40, "Score: ")
        },
        cells = {}
    }

    -- Initialise next_piece cells
    for i = 0, 3 do
        obj.cells[i] = {}
        for j = 0, 3 do
            obj.cells[i][j] = Cell:new(
                next_piece_x + j * cell_size,
                next_piece_y + i * cell_size,
                cell_size
            )
        end
    end

    setmetatable(obj, self)
    self.__index = self
    return obj
end

-- Draw the Sidebar with the time filled in
function Sidebar:draw(next_piece, time, score)
    self.labels.time:draw(time)
    self.labels.score:draw(score)

    for _, row in kalis.ipairs(self.cells) do
        for _, cell in kalis.ipairs(row) do
            cell:draw()
        end
    end
    self:drawNextPiece(next_piece)
end

function Sidebar:drawNextPiece(next_piece)
    for _, coordinate in ipairs(next_piece.coordinates) do
        local cell = self.cells[coordinate.y + 1][coordinate.x - 3]
        cell:draw(next_piece.colour)
    end
end

return Sidebar
