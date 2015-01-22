local Lobby = class('Lobby', Entity)

function Lobby:initialize()
	Entity.initialize(self)

	self.iplist = {}
  self.myhostip = ""
end

function Lobby:updateIpList(list)
  if type(list) == "table" then
    for _,v in ipairs(list) do
      local found = false
      for _,v2 in ipairs(self.iplist) do
        if v == v2 then
          found = true
        end
      end

      if not found then table.insert(iplist, v) end
    end
  elseif type(list) == "string" then
    local found = false
    for _,v2 in ipairs(self.iplist) do
      if v == v2 then
        found = true
      end
    end

    if not found then table.insert(iplist, v) end
  end
end

function Lobby:start(myhostip)
  self.myhostip = myhostip
  table.insert(self.iplist, myhostip)
end

function Lobby:join(hostip)
  print(hostip)
  self:updateIpList(hostip)
  print("lobby join")
  print(i(self.iplist))
  return self.iplist
end

return Lobby
