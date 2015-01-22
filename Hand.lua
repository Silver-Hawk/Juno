local Hand = class('Hand', Entity)

function Hand:initialize()
	Entity.initialize(self)

	self.cards = {}
end

function Hand:addCard(type, color)
	table.insert(self.cards, {type, color}) 
end

function Hand:addCards(t)
  print("in hand:")
  print(i(t))
  for _,v in pairs(t) do
    print(i(v))
    self:addCard(tonumber(v[1]), tonumber(v[2]))
  end

  table.sort(self.cards, 
    function(a,b) 
      return a[2] < b[2] or a[2] == b[2] and a[1] < b[1] 
    end)
end

function Hand:printCards()
	if self.cards then
    for k,v in pairs(self.cards) do
      print(i(v))
    end
  end
end

colorToimageTable = {
    [1] = "blue",
    [2] = "green",
    [3] = "yellow",
    [4] = "red",
    [5] = "black"
}

function Hand:colorToImage(int)
  return colorToimageTable[int+1]
end

function Hand:toJunoNumber(int)
  if int >= 0 and int <= 9 then
    return int
  end

  if int == 10 then return "Ø" end

  return int
end

function drawCard(x, y, txt, image, angle, scale)
    love.graphics.setColor(255,255,255)

    -- rotate around the center of the screen by angle radians
    love.graphics.translate(x, y)
    love.graphics.rotate(math.rad(angle))
    love.graphics.translate(-x, -y)

    love.graphics.draw(image, x, y, 0, scale, scale, 425/2, 500/2)
    love.graphics.setColor(0,0,0)
    
    local font = fonts["font"]
    love.graphics.setFont(font)
    local txtw = font:getWidth(txt)
    local txth = font:getHeight(txt)
    love.graphics.print(txt, x, y, 0, (scale*3), (scale*3), txtw/2, txth/2)
    
    local font = fonts["font_m"]
    love.graphics.setFont(font)
    local txtw = font:getWidth(txt)
    local txth = font:getHeight(txt)
    love.graphics.setColor(0,0,0) --border color
    love.graphics.print(txt, x-(scale*150)-1, y-(scale*165)-1, 0, (scale*3), (scale*3), txtw/2, txth/2)
    love.graphics.print(txt, x-(scale*150)+1, y-(scale*165)-1, 0, (scale*3), (scale*3), txtw/2, txth/2)
    love.graphics.print(txt, x-(scale*150)-1, y-(scale*165)+1, 0, (scale*3), (scale*3), txtw/2, txth/2)
    love.graphics.print(txt, x-(scale*150)+1, y-(scale*165)+1, 0, (scale*3), (scale*3), txtw/2, txth/2)

    love.graphics.print(txt, x+(scale*150)-1, y+(scale*165)-1, math.rad(180), (scale*3), (scale*3), txtw/2, txth/2)
    love.graphics.print(txt, x+(scale*150)+1, y+(scale*165)-1, math.rad(180), (scale*3), (scale*3), txtw/2, txth/2)
    love.graphics.print(txt, x+(scale*150)-1, y+(scale*165)+1, math.rad(180), (scale*3), (scale*3), txtw/2, txth/2)
    love.graphics.print(txt, x+(scale*150)+1, y+(scale*165)+1, math.rad(180), (scale*3), (scale*3), txtw/2, txth/2)


    love.graphics.setColor(255,255,255)
    --love.graphics.print(txt, dx+50, dy-55, 0, 1, 1, txtw/2, (txth/2))
    love.graphics.print(txt, x-(scale*150), y-(scale*165), 0, (scale*3), (scale*3), txtw/2, txth/2)
    love.graphics.print(txt, x+(scale*150), y+(scale*165), math.rad(180), (scale*3), (scale*3), txtw/2, txth/2)
    --love.graphics.print(txt, dx-50, dy+55, 0, 1, 1, txtw/2, (txth/2))
    love.graphics.origin()
end

function Hand:draw()
  local totalspace = 300
  local spacing = totalspace / #self.cards
  local rot = -25
  local middle = 400

  local rotScalePerCard = 60 / #self.cards

  local dx = middle - (spacing * #self.cards)/2
  local dy = 500

  for k,v in pairs(self.cards) do
    drawCard(dx, dy, self:toJunoNumber(tonumber(v[1])),images[self:colorToImage(v[2])], rot, 1/5)
    
    dx = dx + spacing
    rot = rot + rotScalePerCard
  end
end

return Hand
