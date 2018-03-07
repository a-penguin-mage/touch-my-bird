-- touch my bird v0.21b
-- 16 February 2018
-- Chino Nava

-------------------------------------------------------------------
-- Initialize
-------------------------------------------------------------------

-- Libraries
Gamestate = require "hump.gamestate"
Collision = require "collision"

-- Gamestates
local menu = {}
local game = {}
local inst = {}
local dead = {}

--Tables
local scrollingscreen = {}
local birds = {}

-- Images
birdimg = love.graphics.newImage("assets/images/bird.png")
gameback = love.graphics.newImage("assets/images/back.png")
menuback = love.graphics.newImage("assets/images/menuback.png")
loseback = love.graphics.newImage("assets/images/loseback.png")
birdmenu1 = love.graphics.newImage("assets/images/birdmenu1.png")
birdmenu2 = love.graphics.newImage("assets/images/birdmenu2.png")
instructions = love.graphics.newImage("assets/images/instructions.png")

-- Fonts
pixelfont100 = love.graphics.newFont("assets/fonts/pixelmix/pixelmix.ttf",100)

-- Sounds
bgmusic = love.audio.newSource("assets/sounds/bg_music.wav")
death = love.audio.newSource("assets/sounds/death.wav")
gotbird = love.audio.newSource("assets/sounds/death.wav")

-- Constants
TX = love.graphics.getWidth()
TY = love.graphics.getHeight()
fx = TX/720
fy = TY/1080
BIRDSIZE = 125 
H = 8

-- Variables
health = H/H
adder_counter = 0
menu_bird_counter = 0
birds_touched = 0
speedup = 1

-------------------------------------------------------------------
-- Menu functions
-------------------------------------------------------------------
function menu:mousepressed(mx,my)
  Gamestate.switch(inst)
end

function menu:update(dt)
  -- animates the menu bird
  menu_bird_counter = menu_bird_counter+1
  if menu_bird_counter > 50 then 
    if birdmenucurrent == birdmenu1 then birdmenucurrent = birdmenu2
    else birdmenucurrent = birdmenu1 end
    menu_bird_counter = 0;
  end
end

function menu:draw()
  love.graphics.draw(birdmenucurrent,0,0,0,fx,fy)
  love.graphics.draw(menuback,0,0,0,fx,fy)
end

-------------------------------------------------------------------
-- Instruction page functions
-------------------------------------------------------------------
function inst:mousepressed(mx,my)
  Gamestate.switch(game)
  game:getabird()
end

function inst:draw()
  love.graphics.draw(instructions,0,0,0,fx,fy)
end

-------------------------------------------------------------------
-- Game functions
-------------------------------------------------------------------
function game:enter()
  love.audio.play(bgmusic, "static")
  health = H/H
  adder_counter = 0
  menu_bird_counter = 0
  birds_touched = 0
  birds = {}
  speedup = 1      
end

function game:mousepressed(mx, my)
  game:checkbird(mx,my)
end

function game:checkbird(mx,my) 
  for i, bird in ipairs(birds) do
    if Collision:inCircle(bird.x+BIRDSIZE/2*fx, bird.y+BIRDSIZE/2*fy*1.2, BIRDSIZE/2*math.max(fx,fy)*1.2,mx,my) then
      --love.audio.play(gotbird)
      game:getabird()
      birds_touched = birds_touched+1
      table.remove(birds,i)
    end
  end
end

function game:spawnbird(birdx, birdy)
  table.insert(birds,{x = birdx,y = birdy,vel = -1*(120*speedup)})
end

function game:getabird()
  local tempx = love.math.random(BIRDSIZE*fx,TX-BIRDSIZE*fx)
  local tempy = love.math.random(0,TY*0.35-BIRDSIZE*fx)
  game:spawnbird(tempx,tempy)
end

function game:update(dt)
  -- if no bird spawn one
  if #birds==0 then game:getabird() end
  -- check for downfall
  for i, bird in ipairs(birds) do
    if bird.y>TY then
      table.remove(birds,i)
      health = health - 1/H
    end
  end
  
  -- update bird positions
  for i, bird in ipairs(birds) do
    bird.y = bird.y + bird.vel*dt
    if bird.x+BIRDSIZE/2>TX/2 then bird.x = bird.x + 30*speedup*dt
    else bird.x = bird.x - 30*speedup*dt end
    bird.vel = bird.vel+(500*speedup)*dt
  end
  
  -- for adding another bird every n seconds
  if adder_counter>5-speedup then
    game:getabird()
    adder_counter = adder_counter - 5
    speedup = speedup + 0.3
  end
  adder_counter = adder_counter + dt
  
  if health<=0 then      
    Gamestate.push(dead) -- cuz Gamestate.switch() wasn't working right
  end
end

function game:draw()
  love.graphics.setColor(255,255,255)
    
  love.graphics.setColor(255,0,0)
  love.graphics.rectangle("fill",TX/4,TY/4,TX/2,TY/2*health,fx,fy)
    
  -- draw the birds
  for i, bird in ipairs(birds) do
    love.graphics.setColor(255,255,255)
    love.graphics.draw(birdimg, bird.x, bird.y, 0, BIRDSIZE/birdimg:getWidth()*fx, BIRDSIZE/birdimg:getHeight()*fy)
  end
  
  -- draw the counter in the middle of the screen
  love.graphics.setColor(0,0,0)
  love.graphics.setFont(pixelfont100)
  love.graphics.printf(birds_touched,(TX*-1/2)*fx,TY*0.425,TX,"center",0,fx*2,fy*2)
  love.graphics.setColor(255,255,255)
end

-------------------------------------------------------------------
-- Dead functions
-------------------------------------------------------------------
function dead:enter()
  love.audio.stop(bgmusic)
  love.audio.play(death)
end

function dead:draw()
--  if(love.mouse.isDown(1)) then
--    game:enter() -- not the best solution, but it wasn't getting called so...
--    Gamestate.pop()
--  end
  love.graphics.draw(loseback,0,0,0,fx,fy)
  love.graphics.setFont(pixelfont100)
  love.graphics.setColor(255,0,0)
  love.graphics.printf(birds_touched,(TX*-1/2)*fx,TY*0.425,TX,"center",0,fx*2,fy*2)
  love.graphics.setColor(255,255,255)
end


-------------------------------------------------------------------
-- General functions
-------------------------------------------------------------------
function love.update(dt)
  -- update global scrolling screen bg
  for i, back in ipairs(scrollingscreen) do
    back.top = back.top + 10*dt
    if (back.top>TY) then
      back.top = back.top - TY*3
    end
  end
end

function love.load() --initialize
  
  Gamestate.registerEvents()
  Gamestate.switch(menu)
  
  birdmenucurrent = birdmenu1
  
  table.insert(scrollingscreen,{top = 0})
  table.insert(scrollingscreen,{top = -TY})
  table.insert(scrollingscreen,{top = -TY*2})
end

function love.draw()
  -- game scrolling background
  for i, back in ipairs(scrollingscreen) do
    love.graphics.draw(gameback,0,back.top,0,fx,fy)
  end
end

function love.keypressed(key)
  if key=="escape" then love.event.quit() end
end