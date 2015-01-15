local class = require 'middleclass'
local Component = require 'Component'

local CardComponent = class('CardComponent', Component)

function CardComponent:initialize(owner, type, color)
	Component.initialize(self, owner)

	self.type = type
	self.color = color
end

function CardComponent:print()
	print("CardComponent: " .. self.type .. " " .. self.color)
end

return CardComponent
