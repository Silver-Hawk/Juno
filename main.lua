class = require 'middleclass'
Entity = require 'Entity'
i = require 'inspect'

local EC = require 'EntityController'
local Factory = require 'Factory'
local Deck = require 'Deck'
local jc = require('jolieCommunication')

local RG = love.math.newRandomGenerator(love.timer.getTime())

--[[
  cards : 550 / 425
]]

function love.load()
  local s = jc:new()
  s:jolieServer()
  
  print(i(s:requestResponse('sendNumber', {["number"] = 5})))
  
  print(i(s.lastResponse))
  --print(i(s.lastResponse))

  --s:startClient()
  print(i(s:requestResponse('getMessage', {})))
  print(i(s:requestResponse('getMessage', {})))
  print(i(s:requestResponse('getMessage', {})))

  Factory = Factory:new(EC)

  deck = Deck()
  deck:shuffleCards(RG)
  print(i(deck:getCards(7)))

    
end

function love.update(dt)
  EC:update(dt)
end

function love.draw()
  EC:draw()
end
