local GameController = class('GameController', Entity)

function GameController:initialize(myhostip)
	Entity.initialize(self)

  self.clients = {}
  self.clientsCardN = {}
  self.me = myhostip
  self.whoHasTurn = 0
  self.gameisstarted = false
  self.cardinplay = {}
end

function GameController:start(clients)
  self.clients = clients
  self.gameisstarted = true
end

function GameController:setCardsInPlay(t)
  print(i(t))
  local count = 1
  while t["card"..count] ~= nil do
    table.insert(self.cardinplay, t["card"..count])
    count = count + 1
  end
end

function GameController:inplayCard()
  return self.cardinplay
end

function GameController:setTurn(i)
  self.whoHasTurn = tonumber(i)
end

function GameController:giveTurn(skips)
  skips = skips or 0

  --set who has the turn and skip players if any
  self.whoHasTurn = self.whoHasTurn + 1 + skips

  --stay within the player array 
  while self.whoHasTurn > #self.clients do
    self.whoHasTurn = self.whoHasTurn - #self.clients
  end

  return self.whoHasTurn
end

function GameController:gameStarted()
  return self.gameisstarted
end

function GameController:myTurn()
  return self.clients[self.whoHasTurn] == self.me
end

function GameController:getClients()
  return self.clients
end

function GameController:getMyPosId()
  for k,v in ipairs(self.clients) do
    if v == self.me then
      return k
    end
  end
  return 0
end

--containing client as id and number
function GameController:setClientCardNumber(table)
  self.clientsCardN[tonumber(table.id)] = tonumber(table.number)
end

function GameController:draw()
  if self.clients then
    if self.gameisstarted then
      if self:myTurn() then
        love.graphics.print("IT IS MY TURN!!!", 0, 0)
      end

      self:drawOtherPlayers()
    end
  end
end

function GameController:drawOtherPlayers()
  local rotDiff = 360/#self.clients

  --get screen widht and height
  local w, h = love.window.getMode( )
  
  --find the middle
  w = w/2
  h = h/2

  for i=2, #self.clients do
    local curRot =  90 + rotDiff*(i-1)

    local dx = math.cos(math.rad(curRot));
    local dy = math.sin(math.rad(curRot));

    love.graphics.draw(images.back, w+dx*300, h+dy*200, math.rad(curRot-90), 1/3, 1/3, 425/2, 500/2)
    local count = i -1 
    if self.me == self.clients[count] then
      count = count + 1
    end

    if self.clientsCardN[count] then
      love.graphics.setColor(0,0,0)
      local font = fonts["font"]
      love.graphics.setFont(font)
      local txtw = font:getWidth(self.clientsCardN[count])
      local txth = font:getHeight(self.clientsCardN[count])

      love.graphics.print(self.clientsCardN[count], w+dx*300-1, h+dy*200+1, math.rad(curRot-90), 2, 2, txtw/2, txth/2)
      love.graphics.print(self.clientsCardN[count], w+dx*300-1, h+dy*200-1, math.rad(curRot-90), 2, 2, txtw/2, txth/2)
      love.graphics.print(self.clientsCardN[count], w+dx*300+1, h+dy*200+1, math.rad(curRot-90), 2, 2, txtw/2, txth/2)
      love.graphics.print(self.clientsCardN[count], w+dx*300+1, h+dy*200-1, math.rad(curRot-90), 2, 2, txtw/2, txth/2)
      
      love.graphics.setColor(255,255,255)
      love.graphics.print(self.clientsCardN[count], w+dx*300, h+dy*200, math.rad(curRot-90), 2, 2, txtw/2, txth/2)
    end
  end

end


return GameController
