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

  print(i(s:jolieGetIpHost()))
  
  print(i(s:requestResponse('sendNumber', {["number"] = 5})))
  
  print(i(s.lastResponse))
  --print(i(s.lastResponse))

  print("Get message test")
  s:requestResponse('putMessage', {["m"] = 1, ["sender"] = s:getIpAndPort(), ["id"] = 'new'})
  s:requestResponse('putMessage', {["m"] = 2, ["sender"] = s:getIpAndPort(), ["id"] = 'new'})
  s:requestResponse('putMessage', {["m"] = 3, ["sender"] = s:getIpAndPort(), ["id"] = 'new'})
  
  print(i(s:requestResponse('getMessage')))
  print(s:requestResponse('getMessage').id)
  print(s:requestResponse('getMessage').id)
  print(s:requestResponse('getMessage').id)

  print("Get messages test")
  s:requestResponse('putMessage', {["m"] = 4, ["sender"] = s:getIpAndPort(), ["id"] = 'new'})
  s:requestResponse('putMessage', {["m"] = 5, ["sender"] = s:getIpAndPort(), ["id"] = 'new'})
  s:requestResponse('putMessage', {["m"] = 6, ["sender"] = s:getIpAndPort(), ["id"] = 'new'})
  messages = s:requestResponse('getMessages')

  for k,m in pairs(messages) do
  	print (i(m))
  end
  


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
