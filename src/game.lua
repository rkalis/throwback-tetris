local Board = require "src.board"
local Sidebar = require "src.ui.sidebar"
local Settings  = require "src.settings"
local Game = {}


-- Initialise the game (some config can be set here)
-- @Returns
--  the initialised game object
function Game:new()
    local obj = {
        start_time = 0,
        time = 0,
        step_interval = 1,
        step_interval_time = 20,
        move_interval = 0.1,
        move_interval_time = 0,
        sidebar = Sidebar:new(
            NUM_COLS * CELL_SIZE,
            0,
            NUM_COLS * CELL_SIZE + STATS_WIDTH,
            NUM_ROWS * CELL_SIZE
        ),
        board = Board:new(NUM_COLS, NUM_ROWS, CELL_SIZE),
        settings = Settings:new()
    }

    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Game:reset()
    self = Game:new()
    return self
end

return Game
