windowWidth  = love.graphics.getWidth()
windowHeight = love.graphics.getHeight()

-- MKS, meaning Meters, Kilograms and seconds
-- World is 100 meters high by X, respecting the aspect ratio
worldHeight = 100
worldWidth  = worldHeight * windowWidth / windowHeight

widthScale  = windowWidth / worldWidth
heightScale = windowHeight / worldHeight

function load()
  math.randomseed(os.clock())

  fire = love.graphics.newImage("fire.png")

  mainFont  = love.graphics.newFont(love.default_font, 40)
  debugFont = love.graphics.newFont(love.default_font, 12)
  white     = love.graphics.newColor(255, 255, 255)

  woosh = love.audio.newSound("woosh.wav")
  pow   = love.audio.newSound("pow.wav")

  world = love.physics.newWorld(worldWidth, worldHeight)
  -- http://en.wikipedia.org/wiki/Earth's_gravity
  -- Used a slightly higher value to make things look better
  world:setGravity(0, 20)

  bodies  = {}
  shapes  = {}
  symbols = {}
  playing = {}
  colors  = {}
  systems = {}

  lastFire = -10
end

function update(dt)
  if love.timer.getTime() - lastFire > 0.5 then
    if love.keyboard.isDown(love.key_a) then addFirework("A") end
    if love.keyboard.isDown(love.key_j) then addFirework("J") end
  end

  for i = 1, table.maxn(bodies) do
    local body = bodies[i]
    local _, vy = body:getVelocity()
    if playing[i] == false and vy > 0 then
      love.audio.play(pow)
      playing[i] = true
      local px, py = body:getPosition()
      px = px * widthScale
      py = py * heightScale
      table.insert(systems, explosion(px, py))
    end
  end

  local removeables = {}
  for i = 1, table.maxn(bodies) do
    local body = bodies[i]
    local _, y = body:getPosition()
    if y > worldHeight then
      shapes[i]:destroy()
      body:destroy()
      table.insert(removeables, i)
    end
  end

  table.sort(removeables)
  for i = table.maxn(removeables), 1, -1 do
    local idx = removeables[i]
    table.remove(bodies, idx)
    table.remove(shapes, idx)
    table.remove(symbols, idx)
    table.remove(playing, idx)
    table.remove(colors, idx)
  end

  removeables = {}
  for i = 1, table.maxn(systems) do
    if systems[i]:isEmpty() and not systems[i]:isActive() then
      table.insert(removeables, i)
    end
  end

  table.sort(removeables)
  for i = table.maxn(removeables), 1, -1 do
    local idx = removeables[i]
    table.remove(systems, idx)
  end

  world:update(dt)
  for i = 1, table.maxn(systems) do
    systems[i]:update(dt)
  end
end

function draw()
  love.graphics.setFont(mainFont)
  for i = 1, table.maxn(bodies) do
    local body = bodies[i]
    local px, py = body:getPosition()
    local r = shapes[i]:getRadius()
    love.graphics.setColor(colors[i])
    love.graphics.draw(symbols[i], px * widthScale, py * heightScale)
  end

  for i = 1, table.maxn(systems) do
    love.graphics.draw(systems[i], 0, 0)
  end

  love.graphics.setColor(white)
  love.graphics.setFont(debugFont)
  love.graphics.draw("Num: " .. table.maxn(bodies), 10, 12)
  love.graphics.draw("Time: " .. love.timer.getTime(), 10, 26)
  love.graphics.draw("lastFire: " .. lastFire, 10, 40)
end

function keypressed(k)
  if k == love.key_escape then
    love.system.exit()
  end
end

function addFirework(symbol)
  local ax, ay = math.random(0, 60) - 30, math.random(80, 100) * -1
  local body, shape
  body  = love.physics.newBody(world)
  shape = love.physics.newCircleShape(body, 0.75)
  body:setMassFromShapes()
  body:setPosition(math.random(50, worldWidth - 50), worldHeight)
  body:applyImpulse(ax, ay)

  table.insert(bodies, body)
  table.insert(shapes, shape)
  table.insert(symbols, symbol)
  table.insert(playing, false)
  table.insert(colors, randomColor())

  love.audio.play(woosh)
  lastFire = love.timer.getTime()
end

function randomColor()
  local r, g, b = math.random(60, 240), math.random(60, 240), math.random(60, 240)
  return love.graphics.newColor(r, g, b)
end

function explosion(px, py)
  local ps = love.graphics.newParticleSystem(fire, 50)
  ps:setEmissionRate(50)
  ps:setLifetime(0.5)
  ps:setParticleLife(0.5, 1.5)
  ps:setSpread(360)
  ps:setSpeed(30, 80)
  ps:setSize(0.5, 1.5)
  ps:setSizeVariation(1.0)
  ps:setPosition(px, py)
  return ps
end
