local Hand = class('Hand', Entity)

function Hand:initialize()
	Entity.initialize(self)

	self.cards = {}
end

function Hand:addCard(type, color)
	table.insert(self.cards, {type, color}) 
end

function Hand:addCards(t)
  print("in hand:")
  print(i(t))
  for _,v in pairs(t) do
    print(i(v))
    self:addCard(v[1], v[2])
  end
end

function Hand:printCards()
	if self.cards then
    for k,v in pairs(self.cards) do
      print(i(v))
    end
  end
end

return Hand
