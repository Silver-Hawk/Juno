local class = require 'middleclass'
local Component = require 'Component'

local GraphicsComponent = class('GraphicsComponent', Component)

function GraphicsComponent:initialize(owner)
	Component.initialize(self, owner)

	self.owner.attr.image = love.graphics.newImage("test.jpg")
end

function GraphicsComponent:draw()
	love.graphics.draw(self.owner.attr.image, self.owner.attr.x, self.owner.attr.y)
end

return GraphicsComponent
