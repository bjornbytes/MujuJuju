-- Generated with TexturePacker (http://www.codeandweb.com/texturepacker)
-- with a custom export by Stewart Bracken (http://stewart.bracken.bz)
--
-- $TexturePacker:SmartUpdate:cd1f02070b360314d21c23b571d26b46:5ddf301cec5da928b67d6137680275ba:e879a00ca4ca1e52e40894cf40f344b4$
--
--[[------------------------------------------------------------------------
-- Example Usage --

function love.load()
	myAtlas = require("hud")
	batch = love.graphics.newSpriteBatch( myAtlas.texture, 100, "stream" )
end
function love.draw()
	batch:clear()
	batch:bind()
		batch:add( myAtlas.quads['mySpriteName'], love.mouse.getX(), love.mouse.getY() )
	batch:unbind()
	love.graphics.draw(batch)
end

--]]------------------------------------------------------------------------

local TextureAtlas = {}
local Quads = {}
local Texture = love.graphics.newImage( "hud.png" )

Quads["1.dds"] = love.graphics.newQuad(566, 33, 66, 96, 1015, 512 )
Quads["2.dds"] = love.graphics.newQuad(230, 259, 69, 92, 1015, 512 )
Quads["3.dds"] = love.graphics.newQuad(171, 435, 71, 74, 1015, 512 )
Quads["4.dds"] = love.graphics.newQuad(406, 262, 54, 90, 1015, 512 )
Quads["5.dds"] = love.graphics.newQuad(400, 356, 70, 92, 1015, 512 )
Quads["6.dds"] = love.graphics.newQuad(230, 355, 71, 76, 1015, 512 )
Quads["7.dds"] = love.graphics.newQuad(540, 313, 72, 82, 1015, 512 )
Quads["8.dds"] = love.graphics.newQuad(464, 226, 67, 92, 1015, 512 )
Quads["9.dds"] = love.graphics.newQuad(535, 226, 72, 83, 1015, 512 )
Quads["agility"] = love.graphics.newQuad(820, 166, 69, 77, 1015, 512 )
Quads["alacrity"] = love.graphics.newQuad(921, 365, 45, 49, 1015, 512 )
Quads["ambush"] = love.graphics.newQuad(437, 162, 83, 60, 1015, 512 )
Quads["avalanche"] = love.graphics.newQuad(616, 358, 78, 78, 1015, 512 )
Quads["brainfreeze"] = love.graphics.newQuad(776, 327, 68, 67, 1015, 512 )
Quads["briarlance"] = love.graphics.newQuad(769, 250, 74, 73, 1015, 512 )
Quads["burst"] = love.graphics.newQuad(923, 418, 54, 44, 1015, 512 )
Quads["clarity"] = love.graphics.newQuad(305, 353, 91, 87, 1015, 512 )
Quads["conduction"] = love.graphics.newQuad(848, 322, 65, 61, 1015, 512 )
Quads["crystallize"] = love.graphics.newQuad(761, 463, 56, 43, 1015, 512 )
Quads["deathwish"] = love.graphics.newQuad(246, 435, 55, 55, 1015, 512 )
Quads["empoweredstrikes"] = love.graphics.newQuad(474, 322, 62, 83, 1015, 512 )
Quads["equilibrium"] = love.graphics.newQuad(847, 247, 43, 71, 1015, 512 )
Quads["eruption"] = love.graphics.newQuad(776, 398, 71, 61, 1015, 512 )
Quads["fissure"] = love.graphics.newQuad(893, 202, 57, 41, 1015, 512 )
Quads["flow"] = love.graphics.newQuad(894, 247, 54, 54, 1015, 512 )
Quads["fortify"] = love.graphics.newQuad(698, 437, 59, 72, 1015, 512 )
Quads["frame.dds"] = love.graphics.newQuad(437, 33, 125, 125, 1015, 512 )
Quads["frostbite"] = love.graphics.newQuad(537, 459, 56, 50, 1015, 512 )
Quads["frostnova"] = love.graphics.newQuad(895, 3, 83, 77, 1015, 512 )
Quads["frozenorb"] = love.graphics.newQuad(585, 133, 47, 45, 1015, 512 )
Quads["fury"] = love.graphics.newQuad(814, 3, 77, 85, 1015, 512 )
Quads["ghostarmor"] = love.graphics.newQuad(611, 186, 75, 82, 1015, 512 )
Quads["grimreaper"] = love.graphics.newQuad(725, 91, 78, 73, 1015, 512 )
Quads["healthbarBar"] = love.graphics.newQuad(611, 272, 1, 20, 1015, 512 )
Quads["healthbarFrame"] = love.graphics.newQuad(303, 3, 317, 26, 1015, 512 )
Quads["impenetrablehide"] = love.graphics.newQuad(636, 3, 85, 95, 1015, 512 )
Quads["impulse"] = love.graphics.newQuad(954, 202, 58, 52, 1015, 512 )
Quads["infusedcarapace"] = love.graphics.newQuad(391, 452, 74, 57, 1015, 512 )
Quads["inspire"] = love.graphics.newQuad(893, 144, 58, 54, 1015, 512 )
Quads["minion.dds"] = love.graphics.newQuad(3, 3, 296, 252, 1015, 512 )
Quads["moxie"] = love.graphics.newQuad(917, 309, 50, 52, 1015, 512 )
Quads["rend"] = love.graphics.newQuad(690, 186, 58, 81, 1015, 512 )
Quads["retaliation"] = love.graphics.newQuad(540, 399, 72, 56, 1015, 512 )
Quads["rewind"] = love.graphics.newQuad(923, 466, 44, 43, 1015, 512 )
Quads["runestone"] = love.graphics.newQuad(303, 33, 130, 178, 1015, 512 )
Quads["runestoneBroken"] = love.graphics.newQuad(3, 259, 131, 178, 1015, 512 )
Quads["sanctuary"] = love.graphics.newQuad(303, 262, 99, 87, 1015, 512 )
Quads["shadowrush"] = love.graphics.newQuad(469, 452, 64, 57, 1015, 512 )
Quads["shatter"] = love.graphics.newQuad(952, 258, 55, 47, 1015, 512 )
Quads["shiverarmor"] = love.graphics.newQuad(524, 162, 57, 60, 1015, 512 )
Quads["siphon"] = love.graphics.newQuad(138, 259, 88, 172, 1015, 512 )
Quads["staggeringentry"] = love.graphics.newQuad(616, 440, 74, 66, 1015, 512 )
Quads["strength"] = love.graphics.newQuad(851, 387, 66, 56, 1015, 512 )
Quads["taunt"] = love.graphics.newQuad(3, 441, 99, 68, 1015, 512 )
Quads["temperedbastion"] = love.graphics.newQuad(694, 271, 71, 79, 1015, 512 )
Quads["title.dds"] = love.graphics.newQuad(303, 215, 128, 43, 1015, 512 )
Quads["tremor"] = love.graphics.newQuad(698, 354, 74, 79, 1015, 512 )
Quads["tundra"] = love.graphics.newQuad(851, 447, 68, 48, 1015, 512 )
Quads["twinblades"] = love.graphics.newQuad(895, 84, 72, 56, 1015, 512 )
Quads["unbreakable"] = love.graphics.newQuad(616, 272, 74, 82, 1015, 512 )
Quads["veinsofice"] = love.graphics.newQuad(305, 444, 82, 62, 1015, 512 )
Quads["vigor"] = love.graphics.newQuad(752, 168, 64, 78, 1015, 512 )
Quads["vitality"] = love.graphics.newQuad(955, 144, 54, 54, 1015, 512 )
Quads["voidmetal"] = love.graphics.newQuad(106, 441, 61, 68, 1015, 512 )
Quads["wardofthorns"] = love.graphics.newQuad(725, 3, 85, 84, 1015, 512 )
Quads["windchill"] = love.graphics.newQuad(807, 92, 77, 70, 1015, 512 )
Quads["wintersblight"] = love.graphics.newQuad(636, 102, 80, 80, 1015, 512 )

function TextureAtlas:getDimensions(quadName)
	local quad = self.quads[quadName]
	if not quad then
		return nil 
	end
	local x, y, w, h = quad:getViewport()
    return w, h
end

TextureAtlas.quads = Quads
TextureAtlas.texture = Texture

return TextureAtlas
