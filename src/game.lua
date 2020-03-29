local Board = require "src.board"
local Sidebar = require "src.ui.sidebar"
local Settings = require "src.settings"
local class = require "lib.middleclass"


--- @class Game
--- @field new fun(self: Game)
local Game = class("Game")

function Game:initialize()
  self.start_time = 0
  self.time = 0
  self.level = 0
  self.score = 0
  self.back_to_back = 0
  self.lines_cleared = 0
  self.dropping = false
  self.step_interval_time = 20
  self.move_interval = 0.1
  self.move_interval_time = 0
  self.sidebar = Sidebar:new(
    NUM_COLS * CELL_SIZE,
    NUM_COLS * CELL_SIZE + STATS_WIDTH
  )
  self.board = Board:new(self, NUM_COLS, NUM_ROWS, CELL_SIZE)
  self.settings = Settings:new()
end

--- Updates score and back-to-back count depending on number of lines cleared.
--- Also updates level if the required lines are reached.
--- @param num_lines integer @ The number of lines cleared.
function Game:onLinesCleared(num_lines)
  -- Update back-to-back tetris count
  if num_lines >= 4 then
    self.back_to_back = self.back_to_back + 1
  else
    self.back_to_back = 0
  end

  -- Score 100 per line, plus 100 per back-to-back tetris
  local added_score = num_lines * 100 + self.back_to_back * 100
  self.score = self.score + added_score
  self.lines_cleared = self.lines_cleared + num_lines
  if self.lines_cleared >= self.level * 10 + 10 then self.level = self.level + 1 end
end

--- Returns the time a piece spends in one single row
--- @return number @ The time a piece spends in one row
function Game:stepInterval()
  local regularInterval = ((0.8 - self.level * 0.007) ^ self.level)
  return self.dropping and math.min(0.05, regularInterval) or regularInterval
end

-- Returns the time between sideways movements of a piece
--- @return number @ The time between sideways movements
function Game:moveInterval()
  return math.min(0.05, self:stepInterval())
end

--- Resets the game
--- @return Game @ The reset game
function Game:reset()
  self = Game:new()
  return self
end

return Game
