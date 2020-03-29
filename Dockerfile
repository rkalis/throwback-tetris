# BUILD IMAGE
FROM node:10 as build

# Add app source code
WORKDIR /app/src
COPY assets ./assets/
COPY lib ./lib/
COPY src ./src/
COPY main.lua conf.lua ./
RUN sed -i "s/t.version/-- t.version/" conf.lua

# Build app
WORKDIR /app
RUN npm install -g love.js
RUN love.js /app/src /app/dist --title "Throwback Tetris" --memory 67108864
RUN sed -i "s/<p>Built with <a href=\"https:\/\/github.com\/TannerRogalsky\/love.js\">love.js<\/a><\/p>/\
            <p>Created by <a href=\"https:\/\/kalis.me\">Rosco Kalis<\/a> (<a href=\"https:\/\/github.com\/rkalis\/throwback-tetris\">Source<\/a>)<\/p>/" dist/index.html

###############################################################################

# PROD IMAGE
FROM nginx:1.17.0-alpine

# Copy build artifacts from the 'build environment'
COPY --from=build /app/dist /usr/share/nginx/html
