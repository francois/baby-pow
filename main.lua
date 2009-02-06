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

  mainFont = love.graphics.newFont(love.default_font, 12)
  love.graphics.setFont(mainFont)

  world = love.physics.newWorld(worldWidth, worldHeight)
  -- http://en.wikipedia.org/wiki/Earth's_gravity
  -- Used a slightly higher value to make things look better
  world:setGravity(0, 20)

  bodies  = {}
  shapes  = {}
  symbols = {}

  timeout = 0
end

function update(dt)
  for i = 1, table.maxn(bodies) do
    local body = bodies[i]
    local _, vy = body:getVelocity()
    if timeout == 0 and vy > 0 then
      timeout = love.timer.getTime()
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
  end

  world:update(dt)
end

function draw()
  for i = 1, table.maxn(bodies) do
    local body = bodies[i]
    local px, py = body:getPosition()
    local r = shapes[i]:getRadius()
    love.graphics.draw(symbols[i], px * widthScale, py * heightScale)
  end

  love.graphics.draw("Num: " .. table.maxn(bodies), 10, 12)
  if not (timeout == 0) then
    love.graphics.draw("Timeout: " .. timeout, 10, 24)
  end
end

function keypressed(k)
  if k == love.key_escape then
    love.system.exit()
  end

  if k == love.key_j then
    for impulse = -95, -95, -5 do
      local symbol, body, shape
      symbol = "j"
      body   = love.physics.newBody(world)
      shape  = love.physics.newCircleShape(body, 0.75)
      body:setMassFromShapes()
      body:setPosition(math.random(50, worldWidth - 50), worldHeight)
      body:applyImpulse(0, impulse)

      table.insert(bodies, body)
      table.insert(shapes, shape)
      table.insert(symbols, symbol)
    end
  end
end
