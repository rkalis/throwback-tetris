local game = {}

function game:enter(previous, game)
    self.game = game
    assets.audio.background_music:play()
end

function game:update(dt)
    self.game.time = self.game.time + dt
    self.game.step_interval_time = self.game.step_interval_time + dt
    self.game.move_interval_time = self.game.move_interval_time + dt

    if self.game.step_interval_time > self.game.step_interval then
        self.game.step_interval_time = 0
        self.game.board:step('y', 1)
    end

    if self.game.move_interval_time > self.game.move_interval then
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
    self.game.ui:draw(math.floor(self.game.time))
end

function game:keypressed(key)
    if key == 'space' then
        self.game.board:skip()
    elseif key == 'down' then
        self.game.step_interval = self.game.step_interval / 10
    elseif key == 'up' then
        if self.game.board:getActivePiece():canRotate(1) then
            self.game.board:getActivePiece():rotate(1)
        end
    end
end

function game:keyreleased(key)
    if key == 'down' then
        self.game.step_interval = self.game.step_interval * 10
    end
end

return game
