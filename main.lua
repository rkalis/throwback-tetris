-- throwback-tetris/main.lua

---- GLOBALS ----
Assets = require "assets.assets"
Gamestate = require "lib.gamestate"

States = {
  game = require "src.states.game"
}
-----------------

local Game = require "src.game"

function love.load()
  -- Random seed with a few calibration randoms
  math.randomseed(os.time())
  math.random(); math.random(); math.random(); math.random();

  -- Setting of the löve environment variables
  love.graphics.setBackgroundColor(0.66, 0.66, 0.66)
  love.graphics.setFont(love.graphics.newFont(15))

  local game = Game:new()

  Gamestate.registerEvents()
  Gamestate.switch(States.game, game)
end

function love.draw()
  local game = Gamestate:current().game
  game.board:draw()
end
