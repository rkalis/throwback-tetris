local game = {}

function game:enter(previous, game)
    self.game = game
end

function game:update(dt)
    self.game.time = self.game.time + dt
    self.game.step_interval_time = self.game.step_interval_time + dt
    self.game.move_interval_time = self.game.move_interval_time + dt

    if self.game.step_interval_time > self.game.step_interval then
        self.game.step_interval_time = 0
        self.game.board:step()
    end

    self.game.board:update(dt)
end

function game:draw()
    self.game.ui:draw(math.floor(self.game.time))
end

function game:keypressed(key)
    if key == 'space' then
        self.game.board:skip()
    end
    if key == 'down' then
        self.game.step_interval = self.game.step_interval / 10
    end
end

function game:keyreleased(key)
    if key == 'down' then
        self.game.step_interval = self.game.step_interval * 10
    end
end

return game
