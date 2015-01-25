local Lobby = class('Lobby', Entity)

function Lobby:initialize(myhostip)
	Entity.initialize(self)

  print("myhostip is " .. myhostip)
	self.iplist = {myhostip}
  self.myhostip = myhostip
  self.open = false
  self.lobbydraw = true
end

function Lobby:updateIpList(list)
  print("in updateIpList")
  if type(list) == "table" then
    print("list is table")
    for _,v in ipairs(list) do
      local found = false
      for _,v2 in ipairs(self.iplist) do
        if v == v2 then
          found = true
        end
      end

      print("found is " .. tostring(found))
      print("v is " .. tostring(v))

      if not found then 
        table.insert(self.iplist, v) 
      end
    end
  elseif type(list) == "string" then
    local found = false
    for _,v2 in ipairs(self.iplist) do
      if list == v2 then
        found = true
      end
    end

    if not found then
     table.insert(self.iplist, list) 
    end
  end
end

--allows players to join
function Lobby:openLobby()
  self.open = true
end

function Lobby:closeLobby()
  self.open = false
end

function Lobby:getClients()
  return self.iplist
end

function Lobby:join(hostip)
  if self.open then
    self:updateIpList(hostip)
    
    return self.iplist
  else
    return nil
  end
end

function Lobby:draw()
  if self.lobbydraw then
    local y = 0
    for k,v in ipairs(self.iplist) do
      love.graphics.setColor(255, 255, 255)
      love.graphics.print(" [" .. k .. "] " .. v .. " joined the lobby!", 0, y)
      y = y + 25
    end
    if self.open then
      love.graphics.print("Press 'S' to start game", 0, y)
    end

  end
end

function Lobby:update(dt)

end

return Lobby
