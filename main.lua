class = require 'middleclass'
Entity = require 'Entity'
i = require 'inspect'

local EC = require 'EntityController'
local Factory = require 'Factory'
local Deck = require 'Deck'
local Hand = require 'Hand'
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
  hand = Hand()
  --print(i(deck:getCards(7)))

  local t = {["func"] = "getCards", ["args"] = {7, 2}}

  print(s:tableToXml(t))

  if args[2] ~= "8090" then
    print("entered here")
    print(i(s:callExtFunction("getCards", {7, 2} , "socket://localhost:8090", hand, "addCards")))
    --print(i(s:sendMessage(t , "socket://localhost:8090")))
    --print(i(s:sendMessage(t , "socket://localhost:8090")))
  end

  s:addFunction("getCards", deck)
  print(i(s.funcTable))

  
end

function love.update(dt)
  local t = s:getMessage()
  if s:messageLength(t) > 0 then

    if t.m.args then
      print(i(t))

      local u = s:normalizeTable(t.m.args)

      print("invoking callback (".. t.m.func[1] ..") with table: ")
      print(i(u))
      local r = {['response'] = s:invokeCallback(t.m.func[1], unpack(u))}


      print("return to sender")
      print(i(r))
      --return to sender - as elvis would have said
      print(t.sender)

      print(i(s:sendMessage(r, t.sender, t.id)))
    else
      if t.m.response then
        local u = s:normalizeTable(t)
        print(i(s.messageCallback))
        s:invokeCallbackMessageTable(u.id, u.m.response)
      end
    end
  end
  hand:printCards()
  EC:update(dt)
end

function love.draw()
  EC:draw()
end
