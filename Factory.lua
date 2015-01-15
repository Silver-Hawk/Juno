local Entity = require 'Entity'

local InputComponent = require 'InputComponent'
local GraphicsComponent = require 'GraphicsComponent'
local CardComponent = require 'CardComponent'

local Factory = class('Factory')

function Factory:initialize(ec)
	self.entityController = ec
end

function Factory:setEntityController(ec)
	self.entityController = ec
end

function Factory:addEntity(entity)
	self.entityController:addEntity(entity)
end

--create functions here

function Factory:addPlayer()
	en = Entity:new()
  	en:addComponent(InputComponent)
  	en:addComponent(GraphicsComponent)
  	self:addEntity(en)
end

function Factory:addCard(type, color)
	en = Entity:new()
	en:addComponent(CardComponent, type, color)
	self:addEntity(en)
end

function Factory:addDeck()
	en = Entity:new()
	en:addComponent(DeckComponent, type, color)
	self:addEntity(en)
end




return Factory