local love = require("love")

My_background = love.graphics.newImage('bg.png')
My_background:setWrap("repeat", "repeat")
local quad = love.graphics.newQuad(0, 0, My_background:getWidth(), My_background:getHeight(),
    My_background:getWidth(), My_background:getHeight())
local y = 100000

function love.load()
    love.window.setMode(800, 800, { vsync = 0 })
    beam_posx = 0
    beam_posy = 0
    beam_speed = 1
    shoot_timer = 0
    shoot_interval = 0.5
    num_projectiles = 5
    projectiles_spacing = 40
    -- love.window.maximize()
    player = {}
    projectiles = {}
    player.speed = 2
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() - (0.05 * love.graphics.getHeight())
    -- ally_beam = {}
    -- table.insert(ally_beam, { speed = 1, x = player.x, y = player.y })
    -- beam = { speed = 1, x = player.x, y = player.y }
end

function love.update(dt)
    if y == 0 then
        y = 100000
    end
    y = y - 0.1
    if love.keyboard.isDown("right") then
        if player.x > 775 then
            player.x = 775
        end
        player.x = player.x + player.speed
    end
    if love.keyboard.isDown("left") then
        if player.x < 25 then
            player.x = 25
        end
        player.x = player.x - player.speed
    end
    shoot_timer = shoot_timer + dt
    if shoot_timer >= shoot_interval then
        table.insert(projectiles, {
            x = player.x,
            y = player.y,
            speed = beam_speed
        })
        shoot_timer = 0
    end

    for i = #projectiles, 1, -1 do
        projectiles[i].y = projectiles[i].y - projectiles[i].speed
        if projectiles[i].y < -10 then
            table.remove(projectiles, i)
        end
    end
end

function love.draw()
    quad:setViewport(0, y, My_background:getWidth(), My_background:getHeight())
    love.graphics.draw(My_background, quad, 0, 0, 0)
    love.graphics.circle("fill", player.x, player.y, 20)
    -- for bulletIndex, beam in ipairs(ally_beam) do
    --     love.graphics.setColor(0, 1, 0)
    -- love.graphics.rectangle("fill", beam_posx, beam_posy, 4, 8)
    -- end
    for _, projectile in ipairs(projectiles) do
        love.graphics.rectangle("fill", projectile.x-2, projectile.y, 4, 8)
    end
end
