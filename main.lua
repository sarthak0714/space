local love = require("love")

My_background = love.graphics.newImage('bg.png')
My_background:setWrap("repeat", "repeat")
local quad = love.graphics.newQuad(0, 0, My_background:getWidth(), My_background:getHeight(),
    My_background:getWidth(), My_background:getHeight())
local y = 100000

Bullet = love.graphics.newImage("07.png")

-- Load the kitty sprite sheet
local kittySpriteSheet = love.graphics.newImage("kitty.png")
local spriteWidth = 32  -- Adjusted sprite width (check your actual sprite size)
local spriteHeight = 32 -- Adjusted sprite height (check your actual sprite size)
local row = 5           -- 5th row for the player sprite
local playerFrames = {}

-- Extract frames from the 5th row
for i = 0, 3 do -- Assuming there are 4 frames in the 5th row
    table.insert(playerFrames,
        love.graphics.newQuad(i * spriteWidth, (row - 1) * spriteHeight, spriteWidth, spriteHeight,
            kittySpriteSheet:getDimensions()))
end

-- Player animation variables
local currentFrame = 1
local animationTimer = 0
local animationInterval = 0.1 -- Time between frame changes

local Fish = love.graphics.newImage("fish-removebg-preview.png")

function love.load()
    love.window.setMode(800, 800, { vsync = 0 })

    -- Player setup
    player = {}
    player.speed = 2
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() - (0.05 * love.graphics.getHeight())
    player.lives = 3
    player.isAlive = true
    player.invulnerable = false
    player.invulnerableTimer = 0
    player.invulnerableDuration = 2

    -- Game objects
    projectiles = {}
    enemies = {}

    -- Timers
    shoot_timer = 0
    shoot_interval = 0.6
    enemy_spawn_timer = 0
    enemy_spawn_interval = 1.5

    -- Game state
    gameState = "playing"
    score = 0

    -- Enemy properties
    enemy_speed = 2
end

function love.update(dt)
    if gameState == "playing" then
        -- Background scroll
        if y == 0 then
            y = 100000
        end
        y = y - 0.1

        -- Player movement
        if player.isAlive then
            if love.keyboard.isDown("right") then
                player.x = math.min(player.x + player.speed, love.graphics.getWidth() - 25)
            end
            if love.keyboard.isDown("left") then
                player.x = math.max(player.x - player.speed, 25)
            end
        end

        -- Invulnerability timer
        if player.invulnerable then
            player.invulnerableTimer = player.invulnerableTimer + dt
            if player.invulnerableTimer >= player.invulnerableDuration then
                player.invulnerable = false
                player.invulnerableTimer = 0
            end
        end

        -- Shooting logic
        shoot_timer = shoot_timer + dt
        if shoot_timer >= shoot_interval then
            table.insert(projectiles, {
                x = player.x,
                y = player.y - 30, -- Adjusted to match the sprite's visual position
                speed = 3
            })
            shoot_timer = 0
        end

        -- Enemy spawning
        enemy_spawn_timer = enemy_spawn_timer + dt
        if enemy_spawn_timer >= enemy_spawn_interval then
            table.insert(enemies, {
                x = math.random(30, love.graphics.getWidth() - 30),
                y = -20,
                speed = enemy_speed
            })
            enemy_spawn_timer = 0
        end

        -- Update projectiles
        for i = #projectiles, 1, -1 do
            projectiles[i].y = projectiles[i].y - projectiles[i].speed
            if projectiles[i].y < -10 then
                table.remove(projectiles, i)
            end
        end

        -- Update enemies and check collisions
        for i = #enemies, 1, -1 do
            local enemy = enemies[i]
            enemy.y = enemy.y + enemy.speed

            -- Check collision with projectiles
            for j = #projectiles, 1, -1 do
                local projectile = projectiles[j]
                if checkCollision(enemy, projectile, 20) then
                    table.remove(enemies, i)
                    table.remove(projectiles, j)
                    score = score + 100
                    break
                end
            end

            -- Check collision with player
            if not player.invulnerable and checkCollision(enemy, player, 30) then
                player.lives = player.lives - 1
                table.remove(enemies, i)

                if player.lives <= 0 then
                    gameState = "gameover"
                    player.isAlive = false
                else
                    player.invulnerable = true
                    player.invulnerableTimer = 0
                end
                break
            end

            -- Remove enemies that go off screen
            if enemy.y > love.graphics.getHeight() + 20 then
                table.remove(enemies, i)
            end
        end

        -- Update player animation
        animationTimer = animationTimer + dt
        if animationTimer >= animationInterval then
            currentFrame = currentFrame + 1
            if currentFrame > #playerFrames then
                currentFrame = 1
            end
            animationTimer = 0
        end
    elseif gameState == "gameover" and love.keyboard.isDown('r') then
        resetGame()
    end
end

function love.draw()
    -- Draw background
    quad:setViewport(0, y, My_background:getWidth(), My_background:getHeight())
    love.graphics.draw(My_background, quad, 0, 0, 0)

    -- Draw player using the sprite from the 5th row
    if player.isAlive and (not player.invulnerable or math.floor(love.timer.getTime() * 10) % 2 == 0) then
        love.graphics.draw(kittySpriteSheet,
            playerFrames[currentFrame],
            player.x - spriteWidth / 2,
            player.y - spriteHeight / 2 - 30,
            0,
            2.0,
            2.0
        )
    end

    -- Draw projectiles
    for _, projectile in ipairs(projectiles) do
        love.graphics.draw(Bullet,
            projectile.x, projectile.y,
            math.rad(-90), 0.60, 0.25,
            Bullet:getWidth() / 2, Bullet:getHeight() / 2
        )
    end

    -- Draw enemies
    love.graphics.setColor(1, 1, 1) -- White color for enemies
    for _, enemy in ipairs(enemies) do
        love.graphics.circle("fill", enemy.x, enemy.y, 15)
    end
    love.graphics.setColor(1, 1, 1) -- Reset color

    -- Draw UI
    love.graphics.setColor(1, 1, 1)
    for i = 1, player.lives do
        love.graphics.draw(Fish,
            10 + (i - 1) * 35,
            10,
            0,
            0.06,
            0.06
        )
    end
    love.graphics.print("Score: " .. score, 10, 50)

    -- Draw game over screen
    if gameState == "gameover" then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("GAME OVER", love.graphics.getWidth() / 2 - 40, love.graphics.getHeight() / 2 - 10)
        love.graphics.print("Final Score: " .. score, love.graphics.getWidth() / 2 - 45, love.graphics.getHeight() / 2 +
        10)
        love.graphics.print("Press 'R' to restart", love.graphics.getWidth() / 2 - 60, love.graphics.getHeight() / 2 + 30)
    end
end

function checkCollision(obj1, obj2, distance)
    local dx = obj1.x - obj2.x
    local dy = obj1.y - obj2.y
    return math.sqrt(dx * dx + dy * dy) < distance
end

function resetGame()
    player.lives = 3
    player.isAlive = true
    player.invulnerable = false
    player.invulnerableTimer = 0
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() - (0.05 * love.graphics.getHeight())
    projectiles = {}
    enemies = {}
    gameState = "playing"
    score = 0
end
