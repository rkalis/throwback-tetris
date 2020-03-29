--- @class GameState
local game = {}

--- @param previous table @ The previous state
--- @param game Game @ The current game object
function game:enter(previous, game)
  self.game = game

  if self.game.settings.muted then
    love.audio.setVolume(0)
  else
    love.audio.setVolume(self.game.settings.volume)
  end
  Assets.audio.background_music:play()
end

--- @param dt number @ The time since the last frame
function game:update(dt)
  self.game.time = self.game.time + dt
  self.game.step_interval_time = self.game.step_interval_time + dt
  self.game.move_interval_time = self.game.move_interval_time + dt

  if self.game.step_interval_time > self.game:stepInterval() then
    self.game.step_interval_time = 0
    self.game.board:step()
  end

  -- Press + hold to move
  if self.game.move_interval_time > self.game:moveInterval() then
    self.game.move_interval_time = 0

    if love.keyboard.isDown('left') == love.keyboard.isDown('right') then
    elseif love.keyboard.isDown('left') then
      self.game.board:move('x', -1)
    elseif love.keyboard.isDown('right') then
      self.game.board:move('x', 1)
    end
  end
end

function game:draw()
  local next_piece = self.game.board.next_piece
  local time = math.floor(self.game.time)
  local score = self.game.score
  local level = self.game.level
  self.game.sidebar:draw(next_piece, time, score, level)
end

function game:keypressed(key)
  if key == 'space' then
    self.game.board:skip()
  elseif key == 'down' then
    self.game.dropping = true
  elseif key == 'up' then
    local piece = self.game.board:getActivePiece()
    if piece:canRotate() then
      piece:rotate()
    end
  -- Tap to move
  elseif key == 'left' then
    self.game.board:move('x', -1)
    self.game.move_interval_time = -2 * self.game:moveInterval()
  elseif key == 'right' then
    self.game.board:move('x', 1)
    self.game.move_interval_time = -2 * self.game:moveInterval()
  end
end

function game:keyreleased(key)
  if key == 'down' then
    self.game.dropping = false
  end
end

return game
