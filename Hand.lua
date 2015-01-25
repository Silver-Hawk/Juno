local Hand = class('Hand', Entity)

function Hand:initialize()
	Entity.initialize(self)

	self.cards = {}
  self.animations = {}
  self.animationsToBeAdded = {}
end

function Hand:addCard(type, color)
  --type, color, visible, up for picking
	table.insert(self.cards, {type, color, false, 0})

  local w, h = love.window.getMode( )
  self:addDelayedAnimation({type, color}, self.cards[#self.cards], w/2, h/2, 0)
end

function Hand:addAnimation(typeColor, card, index, startX, startY, startR)
  local endx,endy,endr = self:getCardPlace(index-1)
  
  table.insert(self.animations, {tc = typeColor, card = card, x = startX, y = startY, rot = startR, endx = endx, endy = endy, endr = endr})
  flux.to(self.animations[#self.animations], 1, {x = endx, y = endy, rot = endr})
end

function Hand:addDelayedAnimation(typeColor, card, startX, startY, startR)
  table.insert(self.animationsToBeAdded, {typeColor, card, startX, startY, startR})
end

function Hand:update(dt)

  --sort animations
  table.sort(self.animations, 
    function(a,b)
      return a.card[2] < b.card[2] or a.card[2] == b.card[2] and a.card[1] < b.card[1] 
    end)
  --add animations
  for _,v in ipairs(self.animationsToBeAdded) do
    local index = 0
    for k, v2 in ipairs(self.cards) do
      if tostring(v[2]) == tostring(v2) then
        index = k
        break
      end
    end
    self:addAnimation(v[1], v[2], index, v[3], v[4], v[5])
  end
  self.animationsToBeAdded = {}

  --remove animations
  for k,v in ipairs(self.animations) do
    if v.endx == v.x and v.endy == v.y and v.endr == v.rot then
      for k2, v2 in ipairs(self.cards) do
        print(i(v))
        print(i(v2))
        if tostring(v.card) == tostring(v2) then
          print(tostring(v2[3]))
          v2[3] = true
          print(tostring(v2[3]))
          break
        end
      end
      table.remove(self.animations, k)
    end
  end
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

function Hand:getCardNumber()
  return #self.cards
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

function Hand:getCardPlace(index)
  local totalspace = 300
  local spacing = totalspace / #self.cards
  local rot = -25
  local middle = 400

  local rotScalePerCard = 60 / #self.cards

  local dx = middle - (spacing * #self.cards)/2

  dx = dx + spacing*index
  rot = rot + rotScalePerCard*index
  
  local dy = 500 + (math.abs(rot))

  return dx, dy, rot     
end

function Hand:draw()
  --draw animations
  for k,v in ipairs(self.animations) do
    drawCard(v.x, v.y, self:toJunoNumber(tonumber(v.tc[1])),images[self:colorToImage(v.tc[2])], v.rot, 1/5)
  end

  --draw cards
  for k,v in pairs(self.cards) do
    if self:getNearestCard(love.mouse.getX()) == k then
      flux.to(v, 0.25, {[4] = 1})
    else
      flux.to(v, 0.25, {[4] = 0})
    end
    if v[3] then
      local x,y,r = self:getCardPlace(k-1)
      drawCard(x, y-(v[4]*30), self:toJunoNumber(tonumber(v[1])),images[self:colorToImage(v[2])], r, 1/5)
    end
  end
end

function Hand:getNearestCard(mousex)
  local totalspace = 300
  local spacing = totalspace / #self.cards
  
  local middle = 400
  local spcpercard = (spacing * #self.cards)/2

  local dx = middle - totalspace/2

  function round(n)
    return math.floor((math.floor(n*2) + 1)/2)
  end

  print(mousex-dx)
  print(mousex)
  print(dx)
  print(spcpercard)

  return math.max(math.min(round((mousex-dx)/spacing)+1, #self.cards), 1)
end


function Hand:selectCards()
  local ci = self:getNearestCard(love.mouse.getX())
end


return Hand
