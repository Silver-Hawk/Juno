local angle = 0

images = {
  ["back"] = love.graphics.newImage("assets/back.png"),
  ["black"] = love.graphics.newImage("assets/black.png"),
  ["blue"] = love.graphics.newImage("assets/blue.png"),
  ["green"] = love.graphics.newImage("assets/green.png"),
  ["yellow"] = love.graphics.newImage("assets/yellow.png"),
  ["red"] = love.graphics.newImage("assets/red.png")
}

fonts = {
  ["font"] = love.graphics.newFont("assets/LibreBaskerville-Bold.ttf", 64),
  ["font_m"] = love.graphics.newFont("assets/LibreBaskerville-Bold.ttf", 32)
}

function drawCard(x, y, angle, scale)
    love.graphics.setColor(255,255,255)

    -- rotate around the center of the screen by angle radians
    love.graphics.translate(x, y)
    love.graphics.rotate(angle)
    love.graphics.translate(-x, -y)

    love.graphics.draw(images["blue"], x, y, 0, scale, scale, 425/2, 500/2)
    love.graphics.setColor(0,0,0)
    local txt = 2
    
    local font = fonts["font"]
    love.graphics.setFont(font)
    local txtw = font:getWidth(txt)
    local txth = font:getHeight(txt)
    love.graphics.print(txt, x, y, 0, (scale*3), (scale*3), txtw/2, txth/2)
    
    local font = fonts["font_m"]
    love.graphics.setFont(font)
    local txtw = font:getWidth(txt)
    local txth = font:getHeight(txt)
    love.graphics.setColor(255,255,255)
    --love.graphics.print(txt, dx+50, dy-55, 0, 1, 1, txtw/2, (txth/2))
    love.graphics.print(txt, x-(scale*150), y-(scale*165), 0, (scale*3), (scale*3), txtw/2, txth/2)
    love.graphics.print(txt, x+(scale*150), y+(scale*165), math.rad(180), (scale*3), (scale*3), txtw/2, txth/2)
    --love.graphics.print(txt, dx-50, dy+55, 0, 1, 1, txtw/2, (txth/2))
end

function love.draw()
    local dx = 150
    local dy = 150
    drawCard(dx, dy, angle, 1/5)
end

function love.update(dt)
    love.timer.sleep(.01)
    angle = angle + dt * math.pi/2
    angle = angle % (2*math.pi)
end