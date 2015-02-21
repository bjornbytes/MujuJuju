-- Generated with TexturePacker (http://www.codeandweb.com/texturepacker)
-- with a custom export by Stewart Bracken (http://stewart.bracken.bz)
--
-- $TexturePacker:SmartUpdate:43184276971125ec04e1944fe1884ed7:78c970486721e9bdcebdd7dbb3223244:e879a00ca4ca1e52e40894cf40f344b4$
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

Quads["agility"] = love.graphics.newQuad(645, 327, 69, 77, 1097, 510 )
Quads["alacrity"] = love.graphics.newQuad(966, 406, 45, 49, 1097, 510 )
Quads["ambush"] = love.graphics.newQuad(714, 188, 83, 60, 1097, 510 )
Quads["bgBroken"] = love.graphics.newQuad(300, 30, 130, 178, 1097, 510 )
Quads["bgNormal"] = love.graphics.newQuad(2, 256, 131, 178, 1097, 510 )
Quads["brainfreeze"] = love.graphics.newQuad(135, 430, 78, 78, 1097, 510 )
Quads["briarlance"] = love.graphics.newQuad(716, 325, 74, 73, 1097, 510 )
Quads["burst"] = love.graphics.newQuad(1013, 405, 54, 44, 1097, 510 )
Quads["civilization"] = love.graphics.newQuad(627, 91, 85, 68, 1097, 510 )
Quads["clarity"] = love.graphics.newQuad(728, 2, 91, 87, 1097, 510 )
Quads["coldfeet"] = love.graphics.newQuad(938, 298, 56, 50, 1097, 510 )
Quads["conduction"] = love.graphics.newQuad(872, 173, 65, 61, 1097, 510 )
Quads["darkrend"] = love.graphics.newQuad(448, 425, 62, 83, 1097, 510 )
Quads["deathwish"] = love.graphics.newQuad(895, 350, 55, 55, 1097, 510 )
Quads["empower"] = love.graphics.newQuad(63, 436, 67, 68, 1097, 510 )
Quads["empoweredstrikes"] = love.graphics.newQuad(944, 72, 77, 85, 1097, 510 )
Quads["equilibrium"] = love.graphics.newQuad(792, 325, 43, 71, 1097, 510 )
Quads["eruption"] = love.graphics.newQuad(799, 188, 71, 61, 1097, 510 )
Quads["fissure"] = love.graphics.newQuad(996, 306, 57, 41, 1097, 510 )
Quads["flow"] = love.graphics.newQuad(952, 350, 54, 54, 1097, 510 )
Quads["fortify"] = love.graphics.newQuad(2, 436, 59, 72, 1097, 510 )
Quads["frame.dds"] = love.graphics.newQuad(432, 30, 125, 125, 1097, 510 )
Quads["frenzy"] = love.graphics.newQuad(944, 159, 77, 75, 1097, 510 )
Quads["frigidsplinters"] = love.graphics.newQuad(432, 157, 86, 83, 1097, 510 )
Quads["frost"] = love.graphics.newQuad(512, 421, 80, 80, 1097, 510 )
Quads["frostbite"] = love.graphics.newQuad(837, 350, 56, 43, 1097, 510 )
Quads["frozenorb"] = love.graphics.newQuad(1013, 451, 47, 45, 1097, 510 )
Quads["ghostarmor"] = love.graphics.newQuad(371, 426, 75, 82, 1097, 510 )
Quads["grimreaper"] = love.graphics.newQuad(713, 250, 79, 73, 1097, 510 )
Quads["healthbarBar"] = love.graphics.newQuad(939, 173, 3, 22, 1097, 510 )
Quads["healthbarFrame"] = love.graphics.newQuad(300, 2, 317, 26, 1097, 510 )
Quads["hide"] = love.graphics.newQuad(714, 91, 85, 95, 1097, 510 )
Quads["imbue"] = love.graphics.newQuad(496, 248, 81, 87, 1097, 510 )
Quads["impenetrablehide"] = love.graphics.newQuad(714, 91, 85, 95, 1097, 510 )
Quads["impulse"] = love.graphics.newQuad(1011, 252, 58, 52, 1097, 510 )
Quads["infusedcarapace"] = love.graphics.newQuad(225, 370, 74, 57, 1097, 510 )
Quads["inspire"] = love.graphics.newQuad(878, 294, 58, 54, 1097, 510 )
Quads["minion.dds"] = love.graphics.newQuad(2, 2, 296, 252, 1097, 510 )
Quads["moxie"] = love.graphics.newQuad(914, 407, 50, 52, 1097, 510 )
Quads["permafrost"] = love.graphics.newQuad(952, 236, 57, 60, 1097, 510 )
Quads["rend"] = love.graphics.newQuad(594, 420, 58, 81, 1097, 510 )
Quads["retaliation"] = love.graphics.newQuad(878, 236, 72, 56, 1097, 510 )
Quads["rewind"] = love.graphics.newQuad(857, 462, 44, 43, 1097, 510 )
Quads["rune1.dds"] = love.graphics.newQuad(559, 30, 66, 96, 1097, 510 )
Quads["rune2.dds"] = love.graphics.newQuad(801, 91, 69, 92, 1097, 510 )
Quads["rune3.dds"] = love.graphics.newQuad(430, 349, 71, 74, 1097, 510 )
Quads["rune4.dds"] = love.graphics.newQuad(579, 248, 54, 90, 1097, 510 )
Quads["rune5.dds"] = love.graphics.newQuad(872, 79, 70, 92, 1097, 510 )
Quads["rune6.dds"] = love.graphics.newQuad(654, 406, 71, 76, 1097, 510 )
Quads["rune7.dds"] = love.graphics.newQuad(1023, 168, 72, 82, 1097, 510 )
Quads["rune8.dds"] = love.graphics.newQuad(427, 255, 67, 92, 1097, 510 )
Quads["rune9.dds"] = love.graphics.newQuad(1023, 83, 72, 83, 1097, 510 )
Quads["sanctuary"] = love.graphics.newQuad(627, 2, 99, 87, 1097, 510 )
Quads["shatter"] = love.graphics.newQuad(857, 407, 55, 53, 1097, 510 )
Quads["siphon"] = love.graphics.newQuad(135, 256, 88, 172, 1097, 510 )
Quads["spinach"] = love.graphics.newQuad(803, 398, 52, 67, 1097, 510 )
Quads["spiritrush"] = love.graphics.newQuad(821, 2, 100, 75, 1097, 510 )
Quads["staggeringentry"] = love.graphics.newQuad(727, 400, 74, 66, 1097, 510 )
Quads["strength"] = love.graphics.newQuad(559, 128, 66, 56, 1097, 510 )
Quads["sugarrush"] = love.graphics.newQuad(225, 256, 102, 112, 1097, 510 )
Quads["summon"] = love.graphics.newQuad(821, 2, 100, 75, 1097, 510 )
Quads["taunt"] = love.graphics.newQuad(923, 2, 99, 68, 1097, 510 )
Quads["temperedbastion"] = love.graphics.newQuad(1024, 2, 71, 79, 1097, 510 )
Quads["tenacity"] = love.graphics.newQuad(2, 436, 59, 72, 1097, 510 )
Quads["title.dds"] = love.graphics.newQuad(300, 210, 128, 43, 1097, 510 )
Quads["tremor"] = love.graphics.newQuad(295, 429, 74, 79, 1097, 510 )
Quads["twinblades"] = love.graphics.newQuad(520, 186, 83, 60, 1097, 510 )
Quads["unbreakable"] = love.graphics.newQuad(503, 337, 74, 82, 1097, 510 )
Quads["veinsofice"] = love.graphics.newQuad(794, 251, 82, 62, 1097, 510 )
Quads["victoryrush"] = love.graphics.newQuad(301, 370, 64, 57, 1097, 510 )
Quads["vigor"] = love.graphics.newQuad(579, 340, 64, 78, 1097, 510 )
Quads["vitality"] = love.graphics.newQuad(1008, 349, 54, 54, 1097, 510 )
Quads["voidmetal"] = love.graphics.newQuad(367, 356, 61, 68, 1097, 510 )
Quads["ward"] = love.graphics.newQuad(627, 161, 85, 84, 1097, 510 )
Quads["wardofthorns"] = love.graphics.newQuad(627, 161, 85, 84, 1097, 510 )
Quads["wealth"] = love.graphics.newQuad(635, 247, 76, 78, 1097, 510 )
Quads["windchill"] = love.graphics.newQuad(215, 430, 78, 78, 1097, 510 )
Quads["zeal"] = love.graphics.newQuad(329, 255, 96, 99, 1097, 510 )

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
