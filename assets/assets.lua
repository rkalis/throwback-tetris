local assets = {
  graphics = {},
  audio = {
    background_music = love.audio.newSource("assets/audio/background_music.mp3", "static")
  }
}
assets.audio.background_music:setLooping(true)
return assets
