class = require 'middleclass'
Entity = require 'Entity'
i = require 'inspect'
flux = require('flux')

require 'utils'

local EC = require 'EntityController'
local Factory = require 'Factory'
local Deck = require 'Deck'
local Hand = require 'Hand'
local jc = require('jolieCommunication')
local Lobby = require 'Lobby'
local GameController = require 'GameController'

local RG = love.math.newRandomGenerator(love.timer.getTime())

--assets used in the game
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
  --start the jolie message passing server
  s:jolieServer('./jolie-server/test/server.ol','localhost', arg[2])

  --entity component system factory
  Factory = Factory:new(EC)
  
  --create classes that control the logic of the game
  lobby = Lobby(s:getIpAndPortJolieString())
  GC = GameController(s:getIpAndPortJolieString())
  hand = Hand()

  EC:addEntity(lobby)
  EC:addEntity(GC)
  EC:addEntity(hand)

  --fix xml to table at some point
  --  print(i(s:xmlToTable([[<messages><id xsi:type="xsd:string">09f82f2a-9f7f-4679-acf6-981c596a3ea7</id><m><args xsi:type="xsd:double">1.0</args><func xsi:type="xsd:string">getCards</func><type xsi:type="xsd:string">call</type></m><sender xsi:type="xsd:string">socket://localhost:8091</sender><target xsi:type="xsd:string">socket://localhost:8090</target></messages><messages><id xsi:type="xsd:string">f8aecc6e-dfad-48f5-8d6b-36c8ad5ab49f</id><m><args xsi:type="xsd:double">1.0</args><func xsi:type="xsd:string">getCards</func><type xsi:type="xsd:string">call</type></m><sender xsi:type="xsd:string">socket://localhost:8091</sender><target xsi:type="xsd:string">socket://localhost:8090</target></messages>]])))
  s:addFunction("updateIpList", lobby)
  s:addFunction("setClientCardNumber", GC)

  s:addFunction("addCards", hand)
  s:addGenericTrigger("addCards", function()
    s:callMultipleExtFunction("setClientCardNumber", {id = GC:getMyPosId(), number = hand:getCardNumber()}, GC:getClients())
    end)
  
  s:addFunction("startGame", GC, "start")
  s:addGenericTrigger("startGame", function()
    lobby.lobbydraw = false
    end)
  s:addFunction("setTurn", GC)
  s:addFunction("sendInplayCards", GC, "setCardsInPlay")

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
    end )

  end
  
  if arg[2] ~= "8090" then
    --s:callExtFunction("getCards", {5} , "socket://localhost:8090", hand, "addCards")
    --s:callExtFunction("getCards", {5} , "socket://localhost:8090", hand, "addCards")
    --s:callExtFunction("getCards", {5} , "socket://localhost:8090", hand, "addCards")
    --s:callExtFunction("getCards", {5} , "socket://localhost:8090", hand, "addCards")
    print(i(s:callExtFunction("joinLobby", {s:getIpAndPortJolieString()}, "socket://localhost:8090", lobby, "updateIpList")))
  end
end

function love.update(dt)
  --resolve network messages
  s:handleMessage()

  --update card animations
  flux.update(dt)

  --update entities
  EC:update(dt)
end

function love.mousepressed(x, y, button)
  if GC:gameStarted() and GC:myTurn() then
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

function passTurn()
  --get all clients in the game
  local allClients = GC:getClients()
    
  --get and set the id of the next player in line
  local nextPlayer = GC:giveTurn()

  --send the who has the turn to all players
  s:callMultipleExtFunction("setTurn", nextPlayer, allClients)
end
function love.keypressed(key)
  --send currently selected cards
  if key == "return" and GC:gameStarted() and GC:myTurn() then
    --get all clients in the game
    local allClients = GC:getClients()
    --get cards currently selected
    local selectedCards = hand:getSelectedCards()

    --only proceed if there is cards selected 
    if tableLength(selectedCards) > 0 then
      --send cards to other players
      s:callMultipleExtFunction("sendInplayCards", selectedCards, allClients)

      passTurn()
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
  --draw entities
  EC:draw()

  if GC:gameStarted() then
    --print play options
    love.graphics.setFont(fonts.font_m)
    love.graphics.print("Press 'D' to draw a card\nPress enter to send selected cards\nUse mouse left to select card\nUse mouse right to deselect", 600, 500, 0, 1/3)
  end
end
