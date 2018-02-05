-- touch my bird v0.1b
-- 6 February 2018
-- Chino Nava

Gamestate = require "hump.gamestate"

local menu = {}
local game = {}

local function inCircle(cx, cy, radius, x, y) --borrowed
  local dx = cx - x
  local dy = cy - y
  return dx * dx + dy * dy <= radius * radius
end

function love.mousepressed(mx,my)
  if Gamestate.current() == menu then
    Gamestate.switch(game)
    getabird()
  else
    checkbird(mx,my)
  end
end

function checkbird(mx,my) 
  for i, bird in ipairs(birds) do
    if inCircle(bird.x+BIRDSIZE/2*fx, bird.y+BIRDSIZE/2*fy, BIRDSIZE/2*math.max(fx,fy),mx,my) then
      getabird()
      birds_touched = birds_touched+1
      table.remove(birds,i)
    end
  end
end

function spawnbird(birdx, birdy)
  table.insert(birds,{x = birdx,y = birdy,vel = -1*(120*overtime)})
end

function getabird()
  local tempx = love.math.random(0,TX-BIRDSIZE)
  local tempy = love.math.random(0,TY*0.35-BIRDSIZE)
  spawnbird(tempx,tempy)
end

function love.update(dt)
  
  -- if no bird spawn one
  if Gamestate.current() == game and #birds==0 then getabird() end
  
  -- update bird positions
  for i, bird in ipairs(birds) do
    bird.y = bird.y + bird.vel*dt
    bird.vel = bird.vel+(500*overtime)*dt
  end
  
  -- check for downfall
  for i, bird in ipairs(birds) do
    if bird.y>TY then
      table.remove(birds,i)
      HEALTH = HEALTH - 1/H
    end
  end
  
  -- for adding another every n seconds
  TENCOUNTER = TENCOUNTER + dt
  if TENCOUNTER>5 then
    getabird()
    TENCOUNTER = TENCOUNTER - 5
    overtime = overtime + 0.25
  end
end

function love.load()
  TX = love.graphics.getWidth()
  TY = love.graphics.getHeight()
  fx = TX/720
  fy = TY/1080
  birds = {}
  BIRDSIZE = 100
  H = 8
  HEALTH = H/H
  TENCOUNTER = 0
  birds_touched = 0
  overtime = 1
  
  Gamestate.registerEvents()
  Gamestate.switch(menu)
  
  birdimg = love.graphics.newImage("assets/bird.png")
  gameback = love.graphics.newImage("assets/back.png")
  menuback = love.graphics.newImage("assets/menuback.png")
  loseback = love.graphics.newImage("assets/loseback.png")
end

function love.draw()
  
  if Gamestate.current() == game then
    if HEALTH<=0 then      
      -- cover everything if health is 0 (will stop spawn later)
      love.graphics.setColor(255,255,255)
      love.graphics.draw(loseback,0,0,0,fx,fy)
    else
      love.graphics.setColor(255,255,255)
      love.graphics.draw(gameback,0,0,0,fx,fy)
      love.graphics.setColor(255,0,0)
      love.graphics.rectangle("fill",TX/4,TY/4,TX/2,TY/2*HEALTH,fx,fy)
      
      -- draw the birds
      for i, bird in ipairs(birds) do
        love.graphics.setColor(255,255,255)
        love.graphics.draw(birdimg, bird.x, bird.y, 0, BIRDSIZE/birdimg:getWidth()*fx, BIRDSIZE/birdimg:getHeight()*fy)
      end
      
      love.graphics.setColor(0,0,0)
      love.graphics.printf("Birds touched: "..birds_touched,10,TY-55,TX,"left",0,fx*2,fy*2)
    end
    
  else
    love.graphics.setColor(255,255,255)
    love.graphics.draw(menuback,0,0,0,fx,fy)
  end
  
end

function love.keypressed(key)
  if key=="escape" then love.event.quit() end
end