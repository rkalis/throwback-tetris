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
  self.step_interval = 1
  self.step_interval_time = 20
  self.move_interval = 0.1
  self.move_interval_time = 0
  self.sidebar = Sidebar:new(
    NUM_COLS * CELL_SIZE,
    NUM_COLS * CELL_SIZE + STATS_WIDTH
  )
  self.board = Board:new(NUM_COLS, NUM_ROWS, CELL_SIZE)
  self.settings = Settings:new()
end

function Game:reset()
  self = Game:new()
  return self
end

return Game
