class = require 'middleclass'
Entity = require 'Entity'
i = require 'inspect'
flux = require 'flux'

require 'utils'

local EC = require 'EntityController'
local Factory = require 'Factory'
local Deck = require 'Deck'
local Hand = require 'Hand'
local jc = require 'jolieCommunication'
local Lobby = require 'Lobby'
local GameController = require 'GameController'

local RG = love.math.newRandomGenerator(love.timer.getTime())

--
--assets used in the game
--
images = {
  back = love.graphics.newImage("assets/back.png"),
  black = love.graphics.newImage("assets/black.png"),
  blue = love.graphics.newImage("assets/blue.png"),
  green = love.graphics.newImage("assets/green.png"),
  yellow = love.graphics.newImage("assets/yellow.png"),
  red = love.graphics.newImage("assets/red.png")
}

fonts = {
  ["font"] = love.graphics.newFont("assets/LibreBaskerville-Bold.ttf", 64),
  ["font_m"] = love.graphics.newFont("assets/LibreBaskerville-Bold.ttf", 32)
}

--create a jolie communicator class object
s = jc()
  
function love.load()
  --
  --start the jolie message passing server
  --
  s:jolieServer('./jolie-server/server.ol','localhost', arg[2])

  --
  --weak entity component system factory
  --
  Factory = Factory:new(EC)
  
  --
  --create classes that control the logic of the game
  --
  lobby = Lobby(s:getIpAndPortJolieString())
  GC = GameController(s:getIpAndPortJolieString())
  hand = Hand()

  EC:addEntity(lobby)
  EC:addEntity(GC)
  EC:addEntity(hand)

  --
  --expose network functions for all players
  --
  s:addFunction("updateIpList", lobby)
  s:addFunction("setClientCardNumber", GC)

  s:addFunction("addCards", hand)
  s:addGenericTrigger("addCards", function()
    s:callMultipleExtFunction("setClientCardNumber", {id = GC:getMyPosId(), number = hand:getCardNumber()}, GC:getClients())
    end)

  --other players may trigger card draw on this client
  s:addGenericTrigger("getCardsFromHost", function (t)
    s:callExtFunction("getCards", t , "socket://localhost:8090", hand, "addCards")
    s:callMultipleExtFunction("setClientCardNumber", {id = GC:getMyPosId(), number = hand:getCardNumber()+tonumber(t)}, GC:getClients())
    end)
  
  s:addFunction("startGame", GC, "start")
  s:addFunction("setDirection", GC)
  s:addFunction("setWinner", GC)

  s:addGenericTrigger("startGame", function()
    lobby.lobbydraw = false
    end)
  s:addFunction("setTurn", GC)
  s:addFunction("sendInplayCards", GC, "setCardsInPlay")

  --
  -- if port is 8090, then this will be the server
  --
  if arg[2] == "8090" then
    --setup deck for server
    deck = Deck()
    shuffleArray(deck.cards, RG)
    lobby:openLobby()

    --add function that are allowed for external callback for the server
    s:addFunction("getCards", deck)
    s:addFunction("joinLobby", lobby, "join")
    s:addGenericTrigger("joinLobby", function()
    --send all ip adresses to all clients when a client joins using the joinLobby command
    s:callMultipleExtFunction("updateIpList", lobby:getClients(), lobby:getClients())
      end)
  end
  
  --join the server on port 8090
  if arg[2] ~= "8090" then
    s:callExtFunction("joinLobby", {s:getIpAndPortJolieString()}, "socket://localhost:8090", lobby, "updateIpList")
  end
end

function love.update(dt)
  --
  --resolve network messages
  --
  s:handleMessage()

  --
  --check if client has won (if he has 0 cards and there is cards in play)
  --
  if GC:gameStarted() and #GC:inplayCard() > 0 then
    if hand:getCardNumber() == 0 then
      local allClients = GC:getClients()
      --notify all players that there is a winner
      s:callMultipleExtFunction("setWinner", GC.me, allClients)
    end
  end

  --
  --update animations
  --
  flux.update(dt)

  --
  --update entities
  --
  EC:update(dt)
end

function love.mousepressed(x, y, button)
  if GC:gameStarted() and GC:myTurn() and not GC:hasSomebodyWon() then
    if button == "l" then
      --if it's my turn i can select card based on what is in play
      hand:selectCards(GC:inplayCard())
    end
  end

  --if right mouse button is pressed reset selected cards
  if button == "r" then
      hand:unselectCards()
  end
end

--function to pass turn
function passTurn(skips)
  --get all clients in the game
  local allClients = GC:getClients()
    
  --get and set the id of the next player in line
  local nextPlayer = GC:giveTurn(skips)

  --send the who has the turn to all players
  s:callMultipleExtFunction("setTurn", nextPlayer, allClients)
end

function love.keypressed(key)
  --send currently selected cards
  if key == "return" and GC:gameStarted() and GC:myTurn() and not GC:hasSomebodyWon() then
    --get all clients in the game
    local allClients = GC:getClients()
    --get cards currently selected
    local selectedCards = hand:getSelectedCards()

    --only proceed if there is cards selected 
    if tableLength(selectedCards) > 0 then
      --send cards to other players
      s:callMultipleExtFunction("sendInplayCards", selectedCards, allClients)

      --calculate what the rules for the cards are:
      local rule = hand:getCardRules(selectedCards["card1"])
      if rule then
        local selectedCardsNumber = tableLength(selectedCards)
        --skip rule
        if rule == "Ø" then
          --skip the turn for each Ø sent
          passTurn(selectedCardsNumber)
        end

        --add 2 cards for each card sent to the next player
        if rule == "+2" then
          local nextPlayer = GC:giveTurn()

          s:callExtFunction("getCardsFromHost", {selectedCardsNumber*2} , allClients[nextPlayer])

          s:callMultipleExtFunction("setTurn", nextPlayer, allClients)
        end

        --add 4 cards to player and skip his turn
        if rule == "+4" then
          local nextPlayer = GC:giveTurn()

          s:callExtFunction("getCardsFromHost", {selectedCardsNumber*4} , allClients[nextPlayer])

          nextPlayer = GC:giveTurn()
          s:callMultipleExtFunction("setTurn", nextPlayer, allClients)
        end

        --change player direction
        if rule == "R" then
          for i=1,selectedCardsNumber do
            GC:changeDirection()
          end

          s:callMultipleExtFunction("setDirection", GC:getDirection(), allClients)

          passTurn()
        end
      end

      --pass turn if no normal rule was sent
      if not rule then
        passTurn()
      end

      --send how many cards i have to all players (+1 because card aren't added yet)
      s:callMultipleExtFunction("setClientCardNumber", {id = GC:getMyPosId(), number = hand:getCardNumber()}, allClients)
    end
  end

  --draw a card and skip turn
  if key == "d" and GC:gameStarted() and GC:myTurn() then
    --get all clients in the game
    local allClients = GC:getClients()

    --draw a card
    s:callExtFunction("getCards", {1} , "socket://localhost:8090", hand, "addCards")

    passTurn()

    --send how many cards i have to all players (+1 because card aren't added yet)
    s:callMultipleExtFunction("setClientCardNumber", {id = GC:getMyPosId(), number = hand:getCardNumber()+1}, allClients)

    --deselect any cards currently selected
    hand:unselectCards()
  end

  --check if hosts wants to start the game
  if key == "s" and lobby.open == true then
    local allClients = lobby:getClients()
    --shuffle player positions
    shuffleArray(allClients, RG)

    --start the game for all players
    s:callMultipleExtFunction("startGame", allClients, allClients)
    
    --give each player 7 cards
    for _,client in ipairs(allClients) do
      s:callExtFunction("addCards", deck:getCards(7), client)
    end

    --give turn to the first player, let everyone know who has the turn
    s:callMultipleExtFunction("setTurn", 1, allClients)

    --close the lobby so that new players can't join
    lobby:closeLobby()
  end

  --exit when escape is pressed
  if key == "escape" then
    love.event.quit()
  end
end

function love.draw()
  if GC:gameStarted() then
    if not GC:hasSomebodyWon() then
      local lc = GC:lastInplayCard()
      --get last cards in play transparent
      if #lc > 0 then
        local y = 300
        local width = math.min(#lc, 10)
        local count = 1
        for k=math.max(#lc-10,1), #lc do
          local x = 300-(width*30)+30*count
          drawCard(x, y, hand:toJunoNumber(tonumber(lc[k][1]),lc[k][1]),images[hand:colorToImage(lc[k][2])], 0, 1/8)
          count = count + 1
        end 
      end

      local ic = GC:inplayCard()
      --draw cards currently in play
      for k,v in ipairs(ic) do
        local x,y = 300+30*k,300
        drawCard(x, y, hand:toJunoNumber(tonumber(v[1]),v[2]),images[hand:colorToImage(v[2])], 0, 1/6)
      end

      --print play options
      love.graphics.setFont(fonts.font_m)
      love.graphics.print("Press 'D' to draw a card\nPress enter to send selected cards\nUse mouse left to select card\nUse mouse right to deselect", 600, 500, 0, 1/3)
    else
      love.graphics.setFont(fonts.font_m)
      if GC:winnerIsMe() then
        love.graphics.print("I AM THE WINNER!!!!!", 300, 300)
      else
        love.graphics.print("I AM A LOSER!!!!!", 300, 300)
      end
    end
  end

  --draw entities
  EC:draw()
end
