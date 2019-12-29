local assets = {
    graphics = {
    },
    audio = {
        background_music = love.audio.newSource("assets/audio/background_music.wav", "stream")
    }
}
assets.audio.background_music:setLooping(true)
return assets
