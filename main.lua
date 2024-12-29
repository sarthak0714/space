local love = require("love")

Player = {}

Projectile = {}

function love.load()
    love.window.setMode(800, 400, { resizable = true, vsync = 0 })
    love.window.maximize()
    player = Player
    player.speed = 2
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() - (0.05 * love.graphics.getHeight())
    ally_beam = {}
    ally_beam.speed = 1
    ally_beam.x = player.x
    ally_beam.y = player.y
end

function love.update(dt)
    if love.keyboard.isDown("right") then
        player.x = player.x + player.speed
    end
    if love.keyboard.isDown("left") then
        player.x = player.x - player.speed
    end
    ally_beam.y = ally_beam.y - ally_beam.speed
end

function love.draw()
    love.graphics.circle("fill", player.x, player.y, 20)
    love.graphics.rectangle("fill", ally_beam.x, ally_beam.y, 4, 8)
end
