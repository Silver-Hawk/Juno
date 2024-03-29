-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
function libxml.dom.createNode(pNodeType)
    local self = {}    
    
    --===================================================================
    -- OBJECT METATABLE                                                 =
    --===================================================================
    local self_mt = {}    
    ---------------------------------------------------------------------
    self_mt.__tostring = function(t)
        return "[object]:" .. tostring(self.nodeDesc)
    end
    ---------------------------------------------------------------------
    self_mt.__index = function(t,k)
        local mutatorfound = false
        --print(rawget(t,k))    
        
        if rawget(t,k) == nil then
            -- loop through the mutators table to see if we can match a getter
            for i,v in pairs( t.mutators ) do
                --print(i)
                if type(k) == "string" then
                    if ("GET"..k:upper()) == i:upper() then
                        --print("match")
                        return t.mutators[i]()
                    end
                end
            end
            
            --search dom path. ex: node.child.children[3]            
            if rawget(t, "nodeType") ~= nil then                
                if rawget(t, "nodeType") == 1 or rawget(t, "nodeType") == 9 then                    
                    return libxml.dom.searchDomPath(t, k)                    
                end
            end
        else            
            --if no mutator found, simply return the rawget key
            return rawget(t,k)
        end
    end
    ---------------------------------------------------------------------
    self_mt.__newindex = function(t,k,v)                
        local mutatorfound = false
        local mutatorkey = "SET"..k:upper()
        --print(k)        
        if rawget(t, "mutators") then
            -- loop through the mutators table to see if we can match a setter
            for key in pairs(t.mutators) do
                if key:upper() == mutatorkey then                    
                    t.mutators[key](v)
                    mutatorfound = true
                end
            end    
        end        
        --if no mutator found, simply rawset the key and value
        if mutatorfound == false then
            rawset(t,k,v)            
        end        
    end
    ---------------------------------------------------------------------
    
    --===================================================================
    -- PROPERTIES                                                       =
    --===================================================================    
    self.nodeType         = pNodeType    
    ---------------------------------------------------------------------    
    self.nodeDesc        = libxml.dom.nodeTypes[pNodeType]
    ---------------------------------------------------------------------    
    self.attributes     = libxml.dom.createNamedNodeMapObj()
    ---------------------------------------------------------------------
    self.childNodes     = libxml.dom.createNodeList()
    ---------------------------------------------------------------------
    self.parentNode     = nil
    ---------------------------------------------------------------------
    
    --===================================================================
    -- MUTATORS                                                         =
    --===================================================================
    self.mutators = {}
    ---------------------------------------------------------------------
    self.mutators.getId = function()        
        return self.getAttribute("id")
    end
    ---------------------------------------------------------------------
    self.mutators.getFirstChild = function()
        if self.hasChildNodes() then
            return self.childNodes[1]
        else
            return nil
        end
    end
    ---------------------------------------------------------------------
    self.mutators.getLastChild = function()
        if self.hasChildNodes() then
            return self.childNodes[self.childNodes.length]
        else
            return nil
        end
    end
    ---------------------------------------------------------------------
    self.mutators.getPreviousSibling = function()
        if self.parentNode ~= nil then                
            if self.parentNode.hasChildNodes() then                    
                for i=1, self.parentNode.childNodes.length do                        
                    if self == self.parentNode.childNodes[i] and i > 1 then                            
                        return self.parentNode.childNodes[i-1]
                    elseif i == self.parentNode.childNodes.length then
                        return nil
                    end
                end
            else
                return nil
            end
        else
            return nil
        end
    end
    ---------------------------------------------------------------------
    self.mutators.getNextSibling = function()
        if self.parentNode ~= nil then
            if self.parentNode.hasChildNodes() then
                for i=1, self.parentNode.childNodes.length do
                    if self == self.parentNode.childNodes[i] then
                        return self.parentNode.childNodes[i+1]
                    elseif i == self.parentNode.childNodes.length then
                        return nil
                    end
                end
            else
                return nil
            end
        else
            return nil
        end
    end
    ---------------------------------------------------------------------
    self.mutators.getOwnerDocument = function()
        return libxml.document.firstChild
    end
    ---------------------------------------------------------------------
    self.mutators.setId = function(pId)        
        self.setAttribute('id', pId)
    end
    ---------------------------------------------------------------------
    
    --====================================================================
    -- METHODS                                                             =    
    --====================================================================    
    self.appendChild = function(pNodeObj)
        local newNode = self.childNodes.addItem(pNodeObj)
        newNode.parentNode = self
        
        libxml.dom.hasChanged = true
        return newNode
    end    
    ---------------------------------------------------------------------
    self.removeChild = function(pNodeObj)        
        local removedNode = self.childNodes.removeItem(pNodeObj)
        
        libxml.dom.hasChanged = true
        return removedNode
    end
    ---------------------------------------------------------------------
    self.setAttribute = function(pAttributeName, pAttributeValue)
        local attribute = libxml.dom.createAttribute(pAttributeName, pAttributeValue)        
        self.attributes.setNamedItem(attribute)
        
        libxml.dom.hasChanged = true
    end
    ---------------------------------------------------------------------
    self.removeAttribute = function(pAttributeName)
        local attribute = self.attributes.removeNamedItem(self.attributes.getNamedItem(pAttributeName).nodeName)
        
        libxml.dom.hasChanged = true
        return attribute        
    end
    ---------------------------------------------------------------------
    self.getAttribute = function(pAttributeName)                
        if self.attributes ~= nil then
            local attribute = self.attributes.getNamedItem(pAttributeName)        
            if attribute == nil then
                return nil
            else
                return attribute.nodeValue
            end
        else
            return nil
        end
    end
    ---------------------------------------------------------------------
    self.hasChildNodes = function()
        if self.childNodes ~= nil and self.childNodes.length >= 1 then
            return true
        else
            return false
        end
    end
    ---------------------------------------------------------------------
    self.hasAttributes = function()
        if self.attributes ~= nil and self.attributes.length > 0 then
            return true
        else
            return false
        end
    end
    ---------------------------------------------------------------------
    self.hasAttribute = function( pAttribute )
        local response = self.getAttribute(pAttribute)        
        if response ~= nil then
            return true
        else
            return false
        end
    end
    ---------------------------------------------------------------------
    self.hasClass = function( pClass )
        local classes = libxml.split( self.getAttribute("class") or "", "%s" )
        for a=1, #classes do
            if pClass == classes[a] then
                return true
            end
        end
        return false
    end
    ---------------------------------------------------------------------
    self.getElementById = function(pId)                
        return libxml.dom.getElementById(self, pId)
    end
    ---------------------------------------------------------------------
    self.getElementsByTagName = function(pTagName)
        return libxml.dom.getElementsByTagName(self, pTagName)
    end
    ---------------------------------------------------------------------
    self.getElementsByClassName = function(pClassName)
        return libxml.dom.getElementsByClassName(self, pClassName)
    end
    ---------------------------------------------------------------------
    self.replaceChild = function(pNewNode, pOldNode)
        libxml.dom.hasChanged = true
    end
    ---------------------------------------------------------------------
    self.isEqualNode = function(pCompareNode)        
    end
    ---------------------------------------------------------------------
    self.isSameNode = function(pCompareNode)
        if self == pCompareNode then
            return true
        else
            return false
        end
    end    
    ---------------------------------------------------------------------    
    
    setmetatable(self, self_mt)    
    return self
end
-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::