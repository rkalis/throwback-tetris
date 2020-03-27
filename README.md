# Throwback Tetris

This is a Tetris clone that I initially created for the [GitHub Game Off 2017](https://itch.io/jam/game-off-2017), where the theme was throwback. I ended up abandoning the project before it was finished though, so not everything works yet. I've added some minor things over the past years when I felt like it, and I might pick it back up in the future to at least finish it. Currently the game starts playing as soon as you run it, and all game fuctionality works, but there's no way to go game over, so at some point you'll manually have to restart the game.

## Running locally
To run the code locally you need [Lua](https://www.lua.org/) and [LÖVE](https://love2d.org/).

```shell
brew install lua
brew cask install love
```

With those prerequisites installed you can clone the game from GitHub and run it through love.

```shell
git clone git@github.com:rkalis/throwback-tetris.git
cd throwback tetris
love .
```
