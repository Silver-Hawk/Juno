local class = require 'middleclass'
local Component = require 'Component'

local InputComponent = class('InputComponent', Component)

function InputComponent:initialize(owner)
	Component.initialize(self, owner)
end

function InputComponent:update(dt)
	o = self.owner
	if love.keyboard.isDown("left") then
		self.owner.attr['x'] = self.owner.attr['x'] - 100 * dt
	end
	if love.keyboard.isDown("right") then
		self.owner.attr['x'] = self.owner.attr['x'] + 100 * dt
	end
	if love.keyboard.isDown("up") then
		self.owner.attr['y'] = self.owner.attr['y'] - 100 * dt
	end
	if love.keyboard.isDown("down") then
		self.owner.attr['y'] = self.owner.attr['y'] + 100 * dt
	end
end

return InputComponent
