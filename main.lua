-- touch my bird v0.2b
-- 13 February 2018
-- Chino Nava

Gamestate = require "hump.gamestate"
Collision = require "collision"

local menu = {}
local game = {}
local inst = {}
local scrollingscreen = {};

function menu:mousepressed(mx,my)
  Gamestate.switch(inst)
end

function inst:mousepressed(mx,my)
  Gamestate.switch(game)
  getabird()
end

function game:mousepressed(mx, my)
  checkbird(mx,my)
end

function checkbird(mx,my) 
  for i, bird in ipairs(birds) do
    if Collision:inCircle(bird.x+BIRDSIZE/2*fx, bird.y+BIRDSIZE/2*fy*1.2, BIRDSIZE/2*math.max(fx,fy)*1.2,mx,my) then
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
  local tempx = love.math.random(BIRDSIZE*fx,TX-BIRDSIZE*fx)
  local tempy = love.math.random(0,TY*0.35-BIRDSIZE*fx)
  spawnbird(tempx,tempy)
end

function love.update(dt)
  
  -- if no bird spawn one
  if Gamestate.current() == game and #birds==0 then getabird() end
  
  -- update bird positions
  for i, bird in ipairs(birds) do
    bird.y = bird.y + bird.vel*dt
    if bird.x+BIRDSIZE/2>TX/2 then bird.x = bird.x + 30*overtime*dt
    else bird.x = bird.x - 30*overtime*dt end
    bird.vel = bird.vel+(500*overtime)*dt
  end
  
  -- update scrolling screen
  for i, back in ipairs(scrollingscreen) do
    back.top = back.top + 10*dt
    if (back.top>love.graphics.getHeight()) then
      back.top = back.top - love.graphics.getHeight()*3
    end
  end
  
  -- check for downfall
  for i, bird in ipairs(birds) do
    if bird.y>TY then
      table.remove(birds,i)
      HEALTH = HEALTH - 1/H
    end
  end
  
  -- for adding another every n seconds
  if Gamestate.current() == game then TENCOUNTER = TENCOUNTER + dt end
  if TENCOUNTER>5-overtime then
    getabird()
    TENCOUNTER = TENCOUNTER - 5
    overtime = overtime + 0.3
  end
end

function menu:update(dt)
  BIRDMENUCOUNTER = BIRDMENUCOUNTER+1
  if BIRDMENUCOUNTER > 50 then 
    if birdmenucurrent == birdmenu1 then birdmenucurrent = birdmenu2
    else birdmenucurrent = birdmenu1 end
    BIRDMENUCOUNTER = 0;
  end
end

function love.load() --initialize
  TX = love.graphics.getWidth()
  TY = love.graphics.getHeight()
  fx = TX/720
  fy = TY/1080
  birds = {}
  BIRDSIZE = 125 
  H = 8
  HEALTH = H/H
  TENCOUNTER = 0
  BIRDMENUCOUNTER = 0
  birds_touched = 0
  overtime = 1
  
  Gamestate.registerEvents()
  Gamestate.switch(menu)
  
  birdimg = love.graphics.newImage("assets/bird.png")
  gameback = love.graphics.newImage("assets/back.png")
  menuback = love.graphics.newImage("assets/menuback.png")
  loseback = love.graphics.newImage("assets/loseback.png")
  birdmenu1 = love.graphics.newImage("assets/birdmenu1.png")
  birdmenu2 = love.graphics.newImage("assets/birdmenu2.png")
  instructions = love.graphics.newImage("assets/instructions.png")
  birdmenucurrent = birdmenu1
  
  table.insert(scrollingscreen,{top = 0})
  table.insert(scrollingscreen,{top = -love.graphics.getHeight()})
  table.insert(scrollingscreen,{top = -love.graphics.getHeight()*2})
end

function love.draw()

  -- game scrolling background
  for i, back in ipairs(scrollingscreen) do
    love.graphics.draw(gameback,0,back.top,0,fx,fy)
  end
end

function menu:draw()
  love.graphics.draw(birdmenucurrent,0,0,0,fx,fy)
  love.graphics.draw(menuback,0,0,0,fx,fy)
end

function inst:draw()
  love.graphics.draw(instructions,0,0,0,fx,fy)
end

function game:draw()
  if HEALTH<=0 then      
    -- cover everything if health is 0 (will stop spawn later)
    love.graphics.setColor(255,255,255)
    love.graphics.draw(loseback,0,0,0,fx,fy)
  else
    love.graphics.setColor(255,255,255)
      
    love.graphics.setColor(255,0,0)
    love.graphics.rectangle("fill",TX/4,TY/4,TX/2,TY/2*HEALTH,fx,fy)
      
    -- draw the birds
    for i, bird in ipairs(birds) do
      love.graphics.setColor(255,255,255)
      love.graphics.draw(birdimg, bird.x, bird.y, 0, BIRDSIZE/birdimg:getWidth()*fx, BIRDSIZE/birdimg:getHeight()*fy)
    end
      
    love.graphics.setColor(0,0,0)
    love.graphics.printf("Birds touched: "..birds_touched,10,TY-55,TX,"left",0,fx*2,fy*2)
    love.graphics.setColor(255,255,255)
  end
end

function love.keypressed(key)
  if key=="escape" then love.event.quit() end
end