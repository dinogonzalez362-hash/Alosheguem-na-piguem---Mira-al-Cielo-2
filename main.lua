-- main.lua - Mañic: La Gran Persecución Astral (Con Coleccionables y Obstáculos)

local gameState = "STORY"
local currentLevelIndex = 1
local score = 0

local player = {
    x = 100,
    y = 300,
    width = 52,
    height = 72,
    speed = 260,
    yVelocity = 0,
    jumpForce = -720,
    isGrounded = false,
    sprites = {},
    frame = 1,
    animationTimer = 0,
    frameDuration = 0.12
}

local gravity = 1400
local cameraX = 0
local bgStars = {}

-- ESTRUCTURA DE NIVELES CON ÍTEMS Y OBSTÁCULOS
local levels = {
    {
        title = "Nivel 1: El Despertar de Nauoxo",
        story = "En la primavera (Nauoxo), el monte resurge.\nRecolecta las Flores Astrales y evita las espinas del monte.\n\n[ Presiona ESPACIO para comenzar ]",
        playerStart = { x = 100, y = 300 },
        platforms = {
            { x = 0, y = 500, width = 1200, height = 100, name = "Suelo del Monte" },
            { x = 300, y = 380, width = 160, height = 20, name = "Araxanaxaui" },
            { x = 580, y = 290, width = 140, height = 20, name = "Chi’ishe" },
            { x = 850, y = 200, width = 200, height = 20, name = "Lapacho Astral" }
        },
        items = {
            { x = 350, y = 340, width = 16, height = 16, collected = false, name = "Flor Astral" },
            { x = 620, y = 250, width = 16, height = 16, collected = false, name = "Flor Astral" },
            { x = 900, y = 160, width = 16, height = 16, collected = false, name = "Flor Astral" }
        },
        hazards = {
            { x = 500, y = 480, width = 40, height = 20, name = "Espina del Monte" }
        },
        goal = { x = 980, y = 140, width = 40, height = 40 }
    },
    {
        title = "Nivel 2: La Furia de la Abuela Caníbal",
        story = "Esquiva las tramas de fuego de la anciana y recolecta las Huellas de Pioxol para escapar.\n\n[ Presiona ESPACIO para comenzar ]",
        playerStart = { x = 50, y = 400 },
        platforms = {
            { x = 0, y = 520, width = 300, height = 80, name = "Suelo Seguro" },
            { x = 380, y = 420, width = 120, height = 20, name = "Consejo Paloma" },
            { x = 580, y = 320, width = 120, height = 20, name = "Pioxol 1" },
            { x = 780, y = 220, width = 120, height = 20, name = "Pioxol 2" },
            { x = 980, y = 150, width = 180, height = 20, name = "Cielo Seguro" }
        },
        items = {
            { x = 420, y = 380, width = 16, height = 16, collected = false, name = "Espíritu Pioxol" },
            { x = 620, y = 280, width = 16, height = 16, collected = false, name = "Espíritu Pioxol" },
            { x = 820, y = 180, width = 16, height = 16, collected = false, name = "Espíritu Pioxol" }
        },
        hazards = {
            { x = 300, y = 500, width = 80, height = 20, name = "Fuego Trampa" },
            { x = 500, y = 500, width = 80, height = 20, name = "Fuego Trampa" }
        },
        goal = { x = 1050, y = 90, width = 40, height = 40 }
    },
    {
        title = "Nivel 3: La Cacería del Mañic Nqa'aic",
        story = "Sigue el camino de las estrellas sobre las constelaciones para alcanzar al Ñandú.\n\n[ Presiona ESPACIO para comenzar ]",
        playerStart = { x = 100, y = 300 },
        platforms = {
            { x = 0, y = 500, width = 400, height = 100, name = "Suelo del Monte" },
            { x = 320, y = 380, width = 150, height = 20, name = "Dapichí" },
            { x = 550, y = 280, width = 130, height = 20, name = "Vicaic" },
            { x = 800, y = 200, width = 180, height = 20, name = "Peraxanaxal" },
            { x = 1100, y = 140, width = 300, height = 20, name = "Vía Láctea" }
        },
        items = {
            { x = 380, y = 340, width = 16, height = 16, collected = false, name = "Pluma de Mañic" },
            { x = 600, y = 240, width = 16, height = 16, collected = false, name = "Pluma de Mañic" },
            { x = 880, y = 160, width = 16, height = 16, collected = false, name = "Pluma de Mañic" }
        },
        hazards = {
            { x = 400, y = 500, width = 700, height = 20, name = "Abismo Astral" }
        },
        goal = { x = 1280, y = 80, width = 40, height = 40 }
    }
}

function love.load()
    love.window.setTitle("Mañic: La Gran Persecución Astral")
    love.window.setMode(800, 600)

    player.sprites = {
        love.graphics.newImage("niño1.jpg"),
        love.graphics.newImage("niño2.jpg"),
        love.graphics.newImage("niño3.jpg")
    }

    for _, sprite in ipairs(player.sprites) do
        sprite:setFilter("nearest", "nearest")
    end

    for i = 1, 200 do
        table.insert(bgStars, {
            x = math.random(0, 3000),
            y = math.random(0, 600),
            size = math.random(1, 3)
        })
    end
    
    loadLevel(currentLevelIndex)
end

function loadLevel(index)
    local lvl = levels[index]
    player.x = lvl.playerStart.x
    player.y = lvl.playerStart.y
    player.yVelocity = 0
    player.isGrounded = false
    
    -- Reiniciar coleccionables del nivel
    for _, item in ipairs(lvl.items) do
        item.collected = false
    end

    gameState = "STORY"
end

function love.update(dt)
    if gameState ~= "PLAYING" then return end

    local currentLvl = levels[currentLevelIndex]
    local previousX = player.x
    local previousY = player.y
    local isMoving = love.keyboard.isDown("right") or love.keyboard.isDown("d") or love.keyboard.isDown("left") or love.keyboard.isDown("a")

    -- Animación del personaje
    if player.isGrounded then
        if isMoving then
            player.animationTimer = player.animationTimer + dt
            if player.animationTimer >= player.frameDuration then
                player.animationTimer = 0
                player.frame = player.frame + 1
                if player.frame > #player.sprites then
                    player.frame = 1
                end
            end
        else
            player.frame = 1
            player.animationTimer = 0
        end
    else
        player.frame = 3
        player.animationTimer = 0
    end

    -- Movimiento
    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        player.x = player.x + player.speed * dt
    elseif love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        player.x = player.x - player.speed * dt
    end

    -- Gravedad
    player.yVelocity = player.yVelocity + gravity * dt
    player.y = player.y + player.yVelocity * dt

    -- Colisión con Plataformas
    player.isGrounded = false
    for _, plat in ipairs(currentLvl.platforms) do
        if checkCollision(player, plat) then
            local prevBottom = previousY + player.height
            local prevTop = previousY
            local prevRight = previousX + player.width
            local prevLeft = previousX

            if player.yVelocity >= 0 and prevBottom <= plat.y + 12 then
                player.y = plat.y - player.height
                player.yVelocity = 0
                player.isGrounded = true
            elseif player.yVelocity < 0 and prevTop >= plat.y + plat.height - 12 then
                player.y = plat.y + plat.height
                player.yVelocity = 0
            elseif prevRight <= plat.x + 4 and player.x + player.width > plat.x then
                player.x = plat.x - player.width
            elseif prevLeft >= plat.x + plat.width - 4 and player.x < plat.x + plat.width then
                player.x = plat.x + plat.width
            end
        end
    end

    -- Recolección de Ítems
    for _, item in ipairs(currentLvl.items) do
        if not item.collected and checkCollision(player, item) then
            item.collected = true
            score = score + 100
        end
    end

    -- Colisión con Obstáculos/Peligros
    for _, hazard in ipairs(currentLvl.hazards) do
        if checkCollision(player, hazard) then
            loadLevel(currentLevelIndex) -- Reinicia el nivel
            return
        end
    end

    -- Caída fuera del mapa
    if player.y > 700 then
        loadLevel(currentLevelIndex)
    end

    -- Cámara
    cameraX = player.x - 200

    -- Victoria de Nivel
    if checkCollision(player, currentLvl.goal) then
        if currentLevelIndex < #levels then
            currentLevelIndex = currentLevelIndex + 1
            loadLevel(currentLevelIndex)
        else
            gameState = "VICTORY"
        end
    end
end

function love.keypressed(key)
    if gameState == "STORY" then
        if key == "space" or key == "return" then
            gameState = "PLAYING"
        end
    elseif gameState == "PLAYING" then
        if (key == "space" or key == "up" or key == "w") and player.isGrounded then
            player.yVelocity = player.jumpForce
            player.isGrounded = false
        end
    elseif gameState == "VICTORY" then
        if key == "r" or key == "space" then
            score = 0
            currentLevelIndex = 1
            loadLevel(1)
        end
    end
end

function checkCollision(a, b)
    return a.x < b.x + b.width and
           a.x + a.width > b.x and
           a.y < b.y + b.height and
           a.y + a.height > b.y
end

function love.draw()
    love.graphics.clear(0.03, 0.03, 0.12)
    local currentLvl = levels[currentLevelIndex]

    if gameState == "STORY" then
        love.graphics.setColor(1, 0.82, 0.4)
        love.graphics.printf(currentLvl.title, 0, 150, 800, "center")
        
        love.graphics.setColor(0.9, 0.9, 0.9)
        love.graphics.printf(currentLvl.story, 100, 250, 600, "center")

    elseif gameState == "PLAYING" then
        love.graphics.push()
        love.graphics.translate(-cameraX, 0)

        -- Estrellas de fondo
        love.graphics.setColor(1, 1, 1, 0.8)
        for _, star in ipairs(bgStars) do
            love.graphics.circle("fill", star.x, star.y, star.size)
        end

        -- Plataformas
        for _, plat in ipairs(currentLvl.platforms) do
            love.graphics.setColor(0.2, 0.6, 0.9, 0.8)
            love.graphics.rectangle("fill", plat.x, plat.y, plat.width, plat.height, 5, 5)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(plat.name, plat.x + 5, plat.y - 18)
        end

        -- Coleccionables (Ítems Amarillos/Dorados)
        for _, item in ipairs(currentLvl.items) do
            if not item.collected then
                love.graphics.setColor(1, 0.85, 0.2)
                love.graphics.rectangle("fill", item.x, item.y, item.width, item.height, 3, 3)
            end
        end

        -- Obstáculos/Peligros (Rojos)
        for _, hazard in ipairs(currentLvl.hazards) do
            love.graphics.setColor(0.9, 0.2, 0.2)
            love.graphics.rectangle("fill", hazard.x, hazard.y, hazard.width, hazard.height)
        end

        -- Meta (Celeste brillante)
        love.graphics.setColor(0.3, 0.9, 1)
        love.graphics.rectangle("line", currentLvl.goal.x, currentLvl.goal.y, currentLvl.goal.width, currentLvl.goal.height)
        love.graphics.print("Meta", currentLvl.goal.x, currentLvl.goal.y - 15)

        -- Jugador
        local sprite = player.sprites[player.frame]
        if sprite then
            local scaleX = player.width / sprite:getWidth()
            local scaleY = player.height / sprite:getHeight()
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(sprite, player.x, player.y, 0, scaleX, scaleY)
        else
            love.graphics.setColor(0.9, 0.6, 0.2)
            love.graphics.rectangle("fill", player.x, player.y, player.width, player.height, 4, 4)
        end

        love.graphics.pop()

        -- HUD / Interfaz Superior
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Nivel " .. currentLevelIndex .. ": " .. currentLvl.title, 10, 10)
        love.graphics.print("Puntaje: " .. score, 10, 28)

    elseif gameState == "VICTORY" then
        love.graphics.setColor(1, 0.82, 0.4)
        love.graphics.printf("¡COMPLETASTE LA HISTORIA!", 0, 180, 800, "center")
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Puntaje Final: " .. score, 0, 240, 800, "center")

        love.graphics.setColor(0.3, 0.9, 1)
        love.graphics.printf("[ Presiona 'R' o ESPACIO para volver a jugar ]", 0, 320, 800, "center")
    end
end