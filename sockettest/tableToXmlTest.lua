lxp = require ("lxp")
i = require("inspect")

function tableToXml(t)
  local s = ""

  if type(t) == 'table' then
    for k,v in pairs(t) do
    	s = s .. "<" .. k
    	if type(v) == 'number' then
    		s = s .. ' xsi:type="xsd:double">' .. v
    	elseif type(v) == 'string' then
    		s = s .. ' xsi:type="xsd:string">' .. v
    	elseif type(v) == 'table' then
    		s = s .. ">" .. tableToXml(v)
    	end
    	s = s .. "</" .. k .. ">"
    end
  end 
  return s
end

t = {["x"] = "lål den returnerer", ["y"] = 2, ["z"] = 3, ["o"] = {["o"] = {["x"] = 3}}}

function xmlToTable(x)
	local count = 0
	local root = {}
	local levels = {}
	levels[0] = root

	callbacks = {
	    StartElement = function (parser, name, attr)
	        count = count + 1
	        levels[count] = {}
	        levels[count-1][name] = levels[count]
	    end,
	    EndElement = function (parser, name)
	        count = count - 1
	    end,
	    CharacterData = function (parser, string)
	        table.insert(levels[count], string)
	    end
	}

	p = lxp.new(callbacks)

    p:parse(x)          -- parses the line
    p:parse("\n")       -- parses the end of line
	p:parse()               -- finishes the document
	p:close()               -- closes the parser
	
	return root
end
t = {['x'] = t}

print(i(t))
s = tableToXml(t)
print (s)

t = xmlToTable(s)
print(i(t))
