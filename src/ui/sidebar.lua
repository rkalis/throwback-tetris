local Label = require "src.ui.label"
local Cell = require "src.cell"
local kalis = require "lib.kalis"
local class = require "lib.middleclass"


--- @class Sidebar
--- @field new fun(self: Sidebar, left: integer, right: integer)
local Sidebar = class("Sidebar")

--- @param left integer @ The left x coordinate of the Sidebar
--- @param right integer @ The right x coordinate of the Sidebar
function Sidebar:initialize(left, right)
  local width = right - left

  local cell_size = math.floor(width / 10)
  local next_piece_x = left + (width / 2) - (2 * cell_size)
  local next_piece_y = 2 * cell_size

  self.labels = {
    time = Label:new(next_piece_x, next_piece_y + cell_size * 4 + 20, "Time: "),
    score = Label:new(next_piece_x, next_piece_y + cell_size * 4 + 40, "Score: "),
    level = Label:new(next_piece_x, next_piece_y + cell_size * 4 + 60, "Level: ")
  }

  -- Initialise next_piece cells
  self.cells = {}
  for i = 0, 3 do
    self.cells[i] = {}
    for j = 0, 3 do
      self.cells[i][j] = Cell:new(
        next_piece_x + j * cell_size,
        next_piece_y + i * cell_size,
        cell_size
      )
    end
  end
end

--- Draw the Sidebar with the next_piece, time and score filled in
--- @param next_piece Piece @ The next piece to be spawned
--- @param time integer @ The current game time
--- @param score integer @ The current score
--- @param level integer @ The current level
function Sidebar:draw(next_piece, time, score, level)
  self.labels.time:draw(time)
  self.labels.score:draw(score)
  self.labels.level:draw(level)

  for _, row in kalis.ipairs(self.cells) do
    for _, cell in kalis.ipairs(row) do
      cell:draw()
    end
  end
  self:drawNextPiece(next_piece)
end

--- Draw the next piece in the sidebar cells
--- @param next_piece Piece @ The piece to be drawn
function Sidebar:drawNextPiece(next_piece)
  for _, coordinate in ipairs(next_piece.coordinates) do
    local cell = self.cells[coordinate.y + 1][coordinate.x - 3]
    cell:draw(next_piece.colour)
  end
end

return Sidebar
