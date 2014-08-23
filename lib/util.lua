timer = {}
timer.rot = function(v, fn)
	if v > 0 then
		v = v - tickRate
		if v <= 0 then
			v = 0
			v = f.exe(fn) or 0
		end
	end
	return v
end
