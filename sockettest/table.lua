i = require('inspect')
function moreScopes()
	function testT0()
		local l = {1, 2, 3}
		function testT(t)
			a = 1
			while true do
				name, value = debug.getlocal(2, a)
				if not name then break end
				print(name)
				if value == t then
					print(i(value))
				end
				a = a + 1
			end
		end
		testT(l)
	end
	testT0()
end

moreScopes()