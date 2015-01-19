class = require 'middleclass'
Entity = require 'Entity'
i = require 'inspect'

local EC = require 'EntityController'
local Factory = require 'Factory'
local Deck = require 'Deck'
local jc = require('jolieCommunication')

local lom = require("lxp.lom")

local RG = love.math.newRandomGenerator(love.timer.getTime())

--[[
  cards : 550 / 425
]]
s = jc()
  
function love.load(args)

  s:jolieServer('./jolie-server/test/server.ol','localhost', args[2])

  Factory = Factory:new(EC)
  deck = Deck()
  deck:shuffleCards(RG)
  --print(i(deck:getCards(7)))

  local t = {["func"] = "getCards", ["args"] = {7, 2}}

  for k,v in pairs(t) do
    print("k : " .. k)
    
    if type(v) == "table" then
      for k2, v2 in pairs(v) do
        print("\tk2 : " .. k2)
        print("\tv2 : " .. v2)
      end
    else
      print("v : " .. v)
    end
  end

  print(s:tableToXml(t))


  print(i(s:requestResponse("getSyntax",{},false)))


  if args[2] ~= "8090" then
    print("entered here")
    print(i(s:sendMessage(t , "socket://localhost:8090")))
  end

  s:addFunction("getCards", deck)
  print(i(s.funcTable))

end

function love.update(dt)
  local t = s:getMessage()
  if s:messageLength(t) > 0 then
    print(i(t))

    local u = s:normalizeTable(t.m.args)
    
    print("u")
    print(i(u))


    print("invoking callback")
    s:invokeCallback(t.m.func[1], unpack({7, 2}))

    --test = FUNCTIONS[t.m.func[1]](t.m.args)
    print(i(test))
  end
  EC:update(dt)
end

function love.draw()
  EC:draw()
end
