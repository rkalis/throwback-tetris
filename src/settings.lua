local Settings = {}

function Settings:new(muted, volume)
    local obj = {
        muted = muted or false,
        volume = volume or 1.0
    }

    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Settings:toggleMute()
    self.muted = not self.muted
    if self.muted then
        love.audio.setVolume(0)
    else
        love.audio.setVolume(self.volume)
    end
end

function Settings:changeVolume(new_volume)
    self.volume = new_volume
    if not self.muted then
        love.audio.setVolume(self.volume)
    end
end

return Settings
