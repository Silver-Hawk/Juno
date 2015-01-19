local Deck = class('Deck', Entity)

function Deck:initialize(owner)
	Entity.initialize(self)

	self.cards = {}

	--[[
    colors 0-3
    card type:
    0-9 number
    10 skip
    11 change direction
    12 +2

    color 4
    card type:
    0 change color
    1 +4
  ]]

  --create cards in deck
  for i=0,12 do
    for c=0,3 do
      if i == 0 then
        self:addCard(i,c)
      else
        self:addCard(i,c)
        self:addCard(i,c)
      end
    end
  end

  for i=0,3 do
    self:addCard(0,4)
    self:addCard(1,4)
  end

  --make sure that all cards are created
  print(assert(#self.cards) == 108)
end

function Deck:shuffleCards(RG)
	local function shuffle(array)
	    local n = #array
	    local j
	    for i=n+1, 1, -1 do
	        j = RG:random(i)

	        array[j],array[i] = array[i],array[j]
	    end
	    return array
	end

	shuffle(self.cards)
	shuffle(self.cards)
end


function Deck:addCard(type, color)
	table.insert(self.cards, {type, color}) 
end

function Deck:getCards(n)
	
  local cards = {}
	for c = 1,n+1 do
		cards["card"..c] = table.remove(self.cards, c)
	end

	return cards
end

return Deck
