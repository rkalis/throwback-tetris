local game = {}

function game:enter(previous, game)
    self.game = game
end

function game:update(dt)
    self.game.time = self.game.time + dt
    self.game.interval_time = self.game.interval_time + dt
    if self.game.interval_time > self.game.step_interval then
        self.game.interval_time = 0
        self.game.board:step()
    end
end

function game:draw()
    self.game.ui:draw(math.floor(self.game.time))
end

return game
