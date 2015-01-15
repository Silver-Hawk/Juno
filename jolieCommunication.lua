--[[
  Jolie based connector class to send/recieve soap messages

  Jolie-lang.org for more information
]]

class = require 'middleclass'
-- load namespace
local socket = require("socket")
local lxp = require ("lxp")

JC = class('JolieConnector')

function JC:initialize()
  --lua sockets vars
  self.server = nil
  self.client = nil
  self.lastResponse = nil 

  --jolie handler
  self.jhandler = nil

  --host/client data with default
  self.clienthost = "localhost"
  self.clientport = 8090
end

--host defualts to localhost ("*" means localhost), port defualts to 8090
function JC:startServer(host, port)
  self.server = assert(socket.bind(host or "*", port or 8090))
  return self.server
end

function JC:startClient(host, port)
  self.client = assert(socket.connect(self.clienthost or "localhost", self.clientport or 8090))
  return self.client
end

function JC:updateClient(host, port)
  self.clienthost = host or self.clienthost
  self.clientport = port or self.clientport
end

function JC:getIpAndPort()
  if(self.client) then
    local ip, port = self.client:getpeername() end
  if(self.server) then
    local ip, port = self.server:getIpAndPort() end

  return ip, port
end

--time is used for max checking time, 0 is default, 
--meaning that it will check once  
function JC:receive(time, timeout)
  time = time or 0 
  timeout = timeout or 0.5

  local c = self.client
  --c:timeout(0)

  local err = nil
  local line = ""

  --create table to recieve data
  local linesrecieved = {}

  --get new lines until line is end of soap message
  while not err and not string.match(line, "</SOAP") do
      line, err = c:receive()
  
      if line then
        table.insert(linesrecieved, line)
      end
  end

  if #linesrecieved > 0 then
    return linesrecieved
  else
    return false
  end
end

function JC:receiveMessage(time, timeout)
  if self.server then
    self.client = self.server:accept()
    time = time or 0 
    timeout = timeout or 0.5
    
    local t = self:receive(time, timeout)
    if t then
      local m = self:xmlToTable(t[#t])
      m = m["SOAP-ENV:Envelope"]["SOAP-ENV:Body"]
      return m
    else
      return t
    end
  else
    return false
  end
end

function JC:unwrapMessage(action, t)
  if t then
    local m = self:xmlToTable(t[#t])
    m = m["SOAP-ENV:Envelope"]["SOAP-ENV:Body"][action .. "Response"]
    return m
  else
    return t
  end
end
--action is the jolie action that should be invoked
--t is the message should be a table with a tree-like structure
function JC:send(action, t)
  t = t or {}
  t = self:wrapAction(action, t)
  local st = self:toSOAP(action, t)

  local m = 'POST * HTTP/1.1\n' ..
      'Host: localhost\n' ..
      'Connection: close\n' ..
      'Content-Type: text/xml; charset="utf-8"\n' ..
      'Content-Length: ' .. #st .. '\n' ..
      'SOAPAction: "/' .. action .. '"\n' ..
      '\n' .. 
      st

  self.client:send(m)
end

function JC:requestResponse(action, t, unwrapMessage)
  self:startClient() 

  self:send(action, t)
  unwrapMessage = unwrapMessage or true
  
  local r = {}
  while true do
    s, status, partial = self.client:receive("*l")
    --print(s or partial)
    if s ~= "" then
      r[#r+1] = s
    elseif partial ~= "" then
      r[#r+1] = partial
    end
    if status == "closed"then 
      break 
    end
  end

  self.lastResponse = r

  if unwrapMessage then
    return self:unwrapMessage(action, r)
  else
    return r
  end
end

function JC:wrapAction(action, t)
  if t[action] == nil then
    return {[action] = t} 
  else 
    return t 
  end
end

function JC:tableToXml(t)
  local s = ""

  if type(t) == 'table' then
    for k,v in pairs(t) do
      s = s .. "<" .. k
      if type(v) ~= 'table' then
        s = s .. self:variableToXmlNode(v)
      elseif type(v) == 'table' and v[1] ~= nil and type(v[1]) ~= 'table' then
        s = s .. self:variableToXmlNode(v[1])
      elseif type(v) == 'table' then
        s = s .. ">" .. self:tableToXml(v)
      end
      s = s .. "</" .. k .. ">"
    end
  end 
  return s
end

function JC:variableToXmlNode(v)
  local s = ""
  if type(v) == 'number' then
    s = s .. ' xsi:type="xsd:double">' .. v
  elseif type(v) == 'string' then
    s = s .. ' xsi:type="xsd:string">' .. v
  end
  return s
end

--t is the table to transform
function JC:toSOAP(action, t)
  local rt = '<?xml version="1.0" encoding="utf-8"?><SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><SOAP-ENV:Body>'
  rt = rt .. self:tableToXml(t)
  rt = rt .. '</SOAP-ENV:Body></SOAP-ENV:Envelope>'
  return rt
end

function JC:xmlToTable(x)
  local count = 0
  local root = {}
  local levels = {}
  levels[0] = root

  local callbacks = {
      StartElement = function (parser, name, attr)
          count = count + 1
          levels[count] = {}
          namecount = 0
          if(levels[count-1][name]) then
            while(levels[count-1][name..namecount]) do
              namecount = namecount + 1 
            end
            levels[count-1][name..namecount] = levels[count]
          else
            levels[count-1][name] = levels[count]
          end
      end,
      EndElement = function (parser, name)
          count = count - 1
      end,
      CharacterData = function (parser, string)
          table.insert(levels[count], string)
      end
  }

  local p = lxp.new(callbacks)

  p:parse(x)          -- parses the line
  p:parse("\n")       -- parses the end of line
  p:parse()               -- finishes the document
  p:close()               -- closes the parser
  
  return root
end

function JC:jolieServer(path, ip, port)
  port = port or 8090
  self.jhandle = io.popen('jolie ./jolie-server/test/server.ol -C myLocation=\\"socket://localhost:' .. port ..'\\"')
  --self.jhandle = io.popen('jolie ./jolie-server/test/server.ol -C myLocation=\\"socket://localhost:' .. port ..'\\"')
  line = self.jhandle:read()

  print(assert(line) == '[SERVER_START]')
  print("server started")
end

function JC:jolieGetIpHost()
  ip, host = self:startClient():getstats()
  self.client:close()
  return {ip, host}
end


return JC