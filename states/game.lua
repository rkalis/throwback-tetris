local game = {}

function game:enter(previous, game)
    self.game = game
end

function game:update(dt)
    self.game.time = self.game.time + dt
end

function game:draw()
    self.game.ui:draw(math.floor(self.game.time))
end

return game
