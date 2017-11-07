-- throwback-tetris/main.lua

assets = require "assets.assets"
Gamestate = require "lib.gamestate"

states = {
    -- menu = require "states.menu",
    -- pregame = require "states.pregame",
    game = require "states.game"
    -- endgame = require "states.endgame",
    -- enterHighScores = require "states.enterHighScores",
    -- displayHighScores = require "states.displayHighScores"
}

local Game = require "src.game"

function love.load()
    -- Random seed with a few calibration randoms
    math.randomseed(os.time())
    math.random(); math.random(); math.random(); math.random();

    -- Setting of the löve environment variables
    love.graphics.setBackgroundColor(170,170,170)
    love.graphics.setFont(love.graphics.newFont(15))

    local game = Game:new()

    Gamestate.registerEvents()
    Gamestate.switch(states.game, game)
end

function love.draw()
    local game = Gamestate:current().game

    game.board:draw()

    for _, button in pairs(game.ui.buttons) do
        button:draw()
    end
end
