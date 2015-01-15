i = require('inspect')
jc = require('jolieCommunication')

c = jc()

c:jolieServer()
c:startClient()

c:requestResponse('sendNumber', {["number"] = 5})
c:startClient()

c:requestResponse('getMessage', {})