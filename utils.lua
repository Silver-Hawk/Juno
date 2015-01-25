
function shuffleArray(arr, rnd)
	local function shuffle(array)
	    local n = #array
	    local j
	    for i=n, 1, -1 do
	        j = rnd:random(i)

	        array[j],array[i] = array[i],array[j]
	    end
	    return array
	end

	--bad shuffle function
	shuffle(arr)
	shuffle(arr)
end