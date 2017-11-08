local Board = require "src.board"
local Highscores = require "src.highscores"
local UI = require "src.ui.UI"

local Game = {}

function Game:new()
    local obj = {
        start_time = 0,
        time = 0,
        step_interval = 1,
        interval_time = 0,
        difficulty = "medium",
        -- highscores = Highscores:new("highscores_easy.txt",
        --                             "highscores_medium.txt",
        --                             "highscores_hard.txt"),
        ui = UI:new(WINDOW_WIDTH, STATS_HEIGHT),
        board = Board:new(NUM_COLS, NUM_ROWS, CELL_SIZE, STATS_HEIGHT)
    }

    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Game:start(cell)
    self.board:placeMines(cell, self.total_mines)
    self.start_time = love.timer.getTime()
    return self
end

function Game:reset()
    self = Game:new()
    return self
end

return Game
