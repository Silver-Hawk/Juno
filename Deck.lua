local Deck = class('Deck', Entity)

function Deck:initialize()
	Entity.initialize(self)

	self.cards = {}

	--[[
    color 0 = blue
    color 1 = green
    color 2 = yellow
    color 3 = red

    colors 0-3
    card type:
    0-9 number
    10 skip
    11 change direction
    12 +2

    color 4 = black
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
  end

  --make sure that all cards are created
  --left out change color card
  print(assert(#self.cards) == 104)
end

function Deck:addCard(type, color)
	table.insert(self.cards, {type, color}) 
end

function Deck:getCards(n)
	print("n in getCards is:")
  print(n)

  local cards = {}
	for c = 1,n do
		cards["card"..c] = table.remove(self.cards, c)
	end

	return cards
end

return Deck
