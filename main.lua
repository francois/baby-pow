function load()
  mainFont = love.graphics.newFont(love.default_font, 12)
  love.graphics.setFont(mainFont)
end

function update(dt)
end

function draw()
end

function keypressed(k)
  if k == love.key_escape then
    love.system.exit()
  end
end
