local function load(dir)
	for _, file in pairs(love.filesystem.getDirectoryItems(dir)) do
		local path = dir .. '/' .. file
		if string.find(path, '%.lua') and not string.find(path, '%..+%.lua') then
			require(path:gsub('%.lua', ''))
		end
	end

	if love.filesystem.exists(dir .. '.lua') then require(dir) end
end

require 'lib/deps/lutil/util'
require 'lib/deps/spine/love/spine'
load 'lib/deps/slam'

load 'lib'

load 'app/hud'

load 'app/enemies'
load 'app/minions'

load 'app/particles'
load 'app/effects'

load 'app/ctx'
load 'app'
