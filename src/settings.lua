local class = require "lib.middleclass"


--- @class Settings
--- @field new fun(self: Settings, muted: boolean, volume: number)
local Settings = class("Settings")

--- @param muted boolean @ Indicating if the volume is muted
--- @param volume number @ Volume
function Settings:initialize(muted, volume)
  self.muted = muted or false
  self.volume = volume or 1.0
end

--- Toggles mute
function Settings:toggleMute()
  self.muted = not self.muted
  if self.muted then
    love.audio.setVolume(0)
  else
    love.audio.setVolume(self.volume)
  end
end

--- Changes volume
--- @param new_volume number @ The new volume
function Settings:changeVolume(new_volume)
  self.volume = new_volume
  if not self.muted then
    love.audio.setVolume(self.volume)
  end
end

return Settings
