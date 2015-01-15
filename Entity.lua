local class = require 'middleclass'

local Entity = class('Entity')

function Entity:initialize()
	self.components = {}
	self.attr = {}

	--default values
	self.attr['x'] = 0
	self.attr['y'] = 0
end

function Entity:addComponent(component, ...)
	table.insert(self.components, component:new(self, ...))
end

function Entity:getComponent(name)
	for _,v in pairs(self.components) do
		for k,v2 in pairs(v) do
			print (k)
			print (v2)
		end
		if v.name == name then
			return v
		end
	end

	return nil
end

function Entity:update(dt)
	for _,v in pairs(self.components) do
		v:update(dt)
	end
end

function Entity:draw()
	for _,v in pairs(self.components) do
		v:draw()
	end
end

function Entity:print()
	for _,v in pairs(self.components) do
		v:print()
	end
end

return Entity