-- load namespace
local socket = require("socket")
-- create a TCP socket and bind it to the local host, at any port
local server = assert(socket.bind("*", 8090))
-- find out which port the OS chose for us
local ip, port = server:getsockname()
-- print a message informing what's up
print("Please telnet to localhost on port " .. port)
print("After connecting, you have 10s to enter a line to be echoed")
-- loop forever waiting for clients
while 1 do
  -- wait for a connection from any client
  local client = server:accept()
  -- make sure we don't block waiting for this client's line
  client:settimeout(10)
  -- receive the line
  err = nil
  line = ""
  lastline = ""
  linesrecieved = {}
  while not string.match(lastline, "\<\/SOAP") do
      line, err = client:receive()
      --print("match : " .. string.match(line, "\<\/SOAP\-ENV\:Envelope\>"))
      print (line)
      if err then
        print ("err:" .. err)
      end
      if line then
      table.insert(linesrecieved, line)
      end
      lastline = line
  end

  returntext = ""
  linesrecieved[5] = "Content-Length: " .. # linesrecieved[8]
  for k,v in ipairs(linesrecieved) do
    returntext = returntext .. v .. "\n"
    print ("key is " .. k)
    print("inserting .. " .. v)
    print("v is size : " .. #v)
  end
  print (returntext)
  --local line, err = client:receive('*ll')
  -- if there was no error, send it back to the client
  if #linesrecieved > 0 then client:send(returntext) else print("error was " .. err) end
  -- done with client, close the object
  client:close()
end