class = require 'middleclass'
Entity = require 'Entity'
i = require 'inspect'

local EC = require 'EntityController'
local Factory = require 'Factory'
local Deck = require 'Deck'
local Hand = require 'Hand'
local jc = require('jolieCommunication')
local Lobby = require 'Lobby'

local RG = love.math.newRandomGenerator(love.timer.getTime())

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


--[[
  cards : 550 / 425
]]
s = jc()
  
function love.load()
  s:jolieServer('./jolie-server/test/server.ol','localhost', arg[2])

  --entity component system factory
  Factory = Factory:new(EC)

  --local variables used
  iplist = {}

  --[[s:addGenericFunction("updateIpList",
    function (list) 
      for _,v in ipairs(list.iplist) do
        local found = false
        for _,v2 in ipairs(iplist) do
          if v == v2 then
            found = true
          end
        end

        if not found then table.insert(iplist, v) end
      end
    end)]]
  
  local lobby = Lobby()

  if arg[2] == "8090" then
    --setup deck for server
    deck = Deck()
    deck:shuffleCards(RG)
    lobby:start()

    --add function that are allowed for external callback
    s:addFunction("getCards", deck)
    s:addFunction("joinLobby", lobby, "join")
    --setup lobby
    --s:invokeCallback("updateIpList", s:requestResponse("startLobby"))
  end
  hand = Hand()

  if arg[2] ~= "8090" then
    --print(i(s:callExtFunction("getCards", {14} , "socket://localhost:8090", hand, "addCards")))

    print(i(s:callExtFunction("joinLobby", {s:getIpAndPortJolieString()}, "socket://localhost:8090", lobby, "updateIpList")))
  end
  
end

function love.update(dt)
  s:handleMessages()
  EC:update(dt)
end

function love.draw()
  hand:draw()
  EC:draw()
end
