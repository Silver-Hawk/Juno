--[[
  Jolie based connector class to send/recieve SOAP messages

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

  --function callbacks
  self.funcTable = {}
  self.triggers = {}

  --message callbacks
  self.messageCallback = {}
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
  --[[if(self.client) then
    local ip, port = self.client:getpeername() end
  if(self.server) then
    local ip, port = self.server:getIpAndPort() end
  ]]
  local ip, port = self.clienthost, self.clientport
  return ip, port
end

function JC:getIpAndPortJolieString()
  local ip, port = self:getIpAndPort()
  return "socket://".. ip..":" .. port
end

function JC:getHostAndIpFromJolieString(str)
  local sub = string.sub(str, 10)
  local host, ip = sub:match("([^,]+):([^,]+)")
  return {host, ip}
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
    if m["SOAP-ENV:Envelope"] then
      if m["SOAP-ENV:Envelope"]["SOAP-ENV:Body"] then
        m = m["SOAP-ENV:Envelope"]["SOAP-ENV:Body"][action .. "Response"]
      end
    end
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

  return self.client:send(m)
end

function JC:requestResponse(action, t, unwrapMessage)
  self:startClient() 
  self.client:settimeout(5)

  self:send(action, t)
  if unwrapMessage == nil then
    unwrapMessage = true
  end

  local r = {}
  while true do
    local s, status, partial = self.client:receive("*l")

    if s then
      r[#r+1] = s
    elseif partial ~= "" then
      r[#r+1] = partial
    end
    if status == "closed" or status == "timeout" then 
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

function JC:tableToXml(t, parentname)
  local s = ""

  if type(t) == 'table' then
    for k,v in pairs(t) do
      if type(k) == 'number' then
        s = s .. "<" .. parentname .. ">"
        if type(v) ~= 'table' then
          s = s .. v
        else
          s = s .. self:tableToXml(v)
        end 
        s = s .. "</" .. parentname .. ">"
      else
        if type(v) ~= 'table' then
          s = s .. "<" .. k 
          s = s .. self:variableToXmlNode(v)
          s = s .. "</" .. k .. ">"
        elseif type(v) == 'table' and #v == 1 and type(v[1]) ~= "table" then
          s = s .. "<" .. k 
          s = s .. self:variableToXmlNode(v[1])
          s = s .. "</" .. k .. ">"
        elseif type(v) == 'table' and #v > 0 then
          s = s .. self:tableToXml(v, k)
        elseif type(v) == 'table' then
          s = s .. "<" .. k .. ">"
          s = s .. self:tableToXml(v, k)
          s = s .. "</" .. k .. ">"
        end
      end
    end
  end 
  return s
end

function JC:variableToXmlNode(v)
  local s = ""
  if type(v) == 'number' then
    s = s .. ' xsi:type="xsd:double">' .. v
  else --default to string
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
          if(levels[count-1][name]) then
            levels[count] = levels[count-1][name]
          else
            levels[count] = {}
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
  ip = ip or "localhost"

  --socket://localhost:8090
  self.jhandle = io.popen('jolie '.. path ..' -C myLocation=\\"socket://'.. ip ..':' .. port ..'\\" -C targetLocation=\\"\\"')
  --self.jhandle = io.popen('jolie ./jolie-server/test/server.ol -C myLocation=\\"socket://localhost:' .. port ..'\\"')
  line = self.jhandle:read()

  print(assert(line) == '[SERVER_START]')
  print("server started")

  self:updateClient(host, port)
end

function JC:jolieGetIpHost()
  local ip, host = self:startClient():getstats()
  self.client:close()
  return {ip, host}
end

--message handling
function JC:messageLength(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end

function JC:getMessage()
  return self:requestResponse('getMessage')
end

function JC:getMessages()
  return self:requestResponse('getMessages', {}, false)
end

function JC:putMessage(m)
  local t = {["m"] = m, ["sender"] = self:getIpAndPortJolieString(), ["id"] = "new"}
  return self:requestResponse('putMessage', t)
end

function JC:sendMessage(m, target, id)
  local t = {["m"] = m, ["sender"] = self:getIpAndPortJolieString(), ["target"] = target, ["id"] = (id or "new")}

  self:updateClient(unpack(self:getHostAndIpFromJolieString(target)))
  
  local mes = self:requestResponse('putMessage', t)

  self:updateClient(unpack(self:getHostAndIpFromJolieString(t.sender)))

  return mes
end

function JC:callExtFunction(funcId, args, target, callbackobject, callbackfunction)
  local t = {
    ["func"] = funcId,
    ["args"] = args,
    ["type"] = "call"
  }

   local r = self:normalizeTable(self:sendMessage(t, target))

  if callbackobject then
    self:addFunction(r.id, callbackobject, callbackfunction, self.messageCallback)
  end

  return r
end

function JC:callMultipleExtFunction(funcId, args, targets, callbackobject, callbackfunction)
  for _,target in pairs(targets) do
    self:callExtFunction(funcId, args, target, callbackobject, callbackfunction)
  end
end

function JC:handleMessage()
  local t = self:getMessage()
  --parse all messages
  if self:messageLength(t) > 0 then
    --nomalize table for easier accessing
    t = self:normalizeTable(t)

    if self:messageLength(t) > 0 then
      if t.m.type == "call" then
        print("invoking callback (".. t.m.func ..") with table: ")
        print(i(t.m.args))
        local r = nil
        if type(t.m.args) == "table" then
          r = {['type'] = 'response', ['response'] = self:invokeCallback(t.m.func, t.m.args)}
        else
          r = {['type'] = 'response', ['response'] = self:invokeCallback(t.m.func, t.m.args)}
        end

        if self.triggers[t.m.func] then
          print("invoking trigger for function " .. t.m.func)
          self:invokeTrigger(t.m.func, t.m.args)
        end
        
         --return to sender - as elvis would have said
        self:sendMessage(r, t.sender, t.id)
      elseif t.m.type == "response" then
        if type(t.m.args) == "table" then
          self:invokeCallbackMessageTable(t.id, t.m.response)
        else
          self:invokeCallbackMessageTable(t.id, t.m.response)
        end
      end
    end
  end
end

--function handling
--add a trigger to a specific function in the function table
function JC:addGenericTrigger(id, func)
  self.triggers[id] = func
end

function JC:addFunction(id, classobject, classfunction, specificFunctable)
  classfunction = classfunction or id
  --use table specified or default to function table
  specificFunctable = specificFunctable or self.funcTable
  
  specificFunctable[id] = 
  function (...)
    return classobject[classfunction](classobject, ...)
  end
end

function JC:addGenericFunction(id, func, specificFunctable)
  specificFunctable = specificFunctable or self.funcTable
  specificFunctable[id] = func
end


function JC:invokeCallback(id, ...)
  print("in invoke callback " .. tostring(id) .. "with ... as " .. i(...))
  if self.funcTable[id] then
    return self.funcTable[id](...)
  else
    print("callback of function " .. tostring(id) .. " isn't possible, function doesn't exist in table.")
    return nil
  end
end

function JC:invokeTrigger(id, ...)
  if self.triggers[id] then
    return self.triggers[id](...)
  else
    print("trigger of function " .. tostring(id) .. " isn't possible, function doesn't exist in table.")
    return nil
  end
end

function JC:invokeCallbackMessageTable(id, ...)
  if self.messageCallback[id] then
    local res = self.messageCallback[id](...)
    --remove callback after it has been used
    self.messageCallback[id] = nil
    return res
  else
    print("callback of function " .. tostring(id) .. " isn't possible, function doesn't exist in table.")
    return nil
  end
end

--converts a table to a more well structured tree 
function JC:normalizeTable(t)
  local _t = {}

  for k,v in pairs(t) do
    if type(v) == "table" and #v == 1 then
      if type(v[1]) == "table" then 
        _t[k] = self:normalizeTable(v[1])
      else
        _t[k] = v[1]
      end
    elseif type(v) == "table" then
      _t[k] = self:normalizeTable(v)
    else
      _t[k] = v
    end
  end

  return _t
end

return JC 