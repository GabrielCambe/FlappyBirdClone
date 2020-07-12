push = require 'push'
Class = require 'class'
require 'Bird'
require 'Pipe'
require 'PipePair'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

local background = love.graphics.newImage('background.png')
backgroundScroll = 0

local ground = love.graphics.newImage('ground.png')
groundScroll = 0

local BACKGROUND_SCROLL_SPEED = 30
local BACKGROUND_LOOPING_POINT = 413

local GROUND_SCROLL_SPEED = 60
local GROUND_LOOPING_POINT = 514

local bird = Bird()

-- local pipes = {}
local pipePairs = {}

local spawn_timer = 0

local lastY = -PIPE_HEIGHT + math.random(80) +20

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Flappy Bird')

    math.randomseed(os.time())

    push:setupScreen(
        VIRTUAL_WIDTH, VIRTUAL_HEIGHT,
        WINDOW_WIDTH, WINDOW_HEIGHT,
        {
            vsync = true,
            fullscreen = false,
            resizable = true
        }
    )

    love.keyboard.keyPressed = {}
end

function love.update(dt)
    backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt)
        % BACKGROUND_LOOPING_POINT
    groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt)
        % GROUND_LOOPING_POINT

    spawn_timer = spawn_timer + dt
    if spawn_timer > 2 then
        local y = math.max(
                    -PIPE_HEIGHT + 10,
                    math.min(
                        lastY + math.random(-20,20),
                        VIRTUAL_HEIGHT - 90 - PIPE_HEIGHT
                    )
                )
        lastY = y
        -- table.insert( pipes, Pipe())
        table.insert( pipePairs, PipePair(y))
        spawn_timer = 0
    end

    bird:update(dt)

    for k, pair in pairs(pipePairs) do
        pair:update(dt)    
    end

    for k, pair in pairs(pipePairs) do
        if pair.remove then
            table.remove( pipePairs, k )
        end    
    end

    love.keyboard.keyPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    love.keyboard.keyPressed[key] = true
    if key == 'escape' then
        love.event.quit()
    end
end

function love.keyboard.wasPressed(key)
    if love.keyboard.keyPressed[key] then
        return true
    else
        return false
    end
end

function love.draw()
    push:start()

    love.graphics.draw(background, -backgroundScroll, 0)
   
    for k, pair in pairs(pipePairs) do
        pair:render()
    end

    love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT-16)

    bird:render()

    push:finish()
end