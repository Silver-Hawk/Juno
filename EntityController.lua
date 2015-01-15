local class = require 'middleclass'

local Entity = class('Entity')
local EntityController = class('EntityController')

function EntityController:initialize()
	self.Entities = {}
end

function EntityController:update(dt)
	for _,v in pairs(self.Entities) do
		v:update(dt)
	end
end

function EntityController:draw()
	for _,v in pairs(self.Entities) do	
		v:draw()
	end
end

function EntityController:print()
	for _,v in pairs(self.Entities) do	
		v:print()
	end
end

function EntityController:getLatestEntity()
	return self.Entities[#self.Entities]
end

function EntityController:addEntity(entity)
	table.insert(self.Entities, entity)
end

function EntityController:getNumEntities()
	return #self.Entities
end

function EntityController:shuffleEntities(RG)
	local function shuffle(array)
	    local n = #array
	    local j
	    for i=n+1, 1, -1 do
	        j = RG:random(i)

	        array[j],array[i] = array[i],array[j]
	    end
	    return array
	end

	shuffle(self.Entities)
	shuffle(self.Entities)
end


return EntityController:new()