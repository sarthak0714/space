local love = require("love")

function love.load()
    love.window.setMode(800, 400, { resizable = true, vsync = 0 })
    love.window.maximize()
    player = {}
    player.speed = 2
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() - (love.graphics.getHeight() * 0.1)
end

function love.update(dt)
    if love.keyboard.isDown("right") then
        player.x = player.x + player.speed
    end
    if love.keyboard.isDown("left") then
        player.x = player.x - player.speed
    end
end

function love.draw()
    love.graphics.circle("fill", player.x, player.y, 20)
end
