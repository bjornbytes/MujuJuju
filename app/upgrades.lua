Upgrades = {}

Upgrades.clear = function()
	Upgrades.canBuy = function(who, what)
    local p = ctx.player
		local upgrade = data.unit[who].upgrades[what]
    if p.skillPoints == 0 then return false end
    if p.level < upgrade.levelRequirement then return false end
    if upgrade.level >= upgrade.maxLevel then return false end
		return Upgrades.checkPrerequisites(who, what)
	end

	Upgrades.checkPrerequisites = function(who, what)
		local upgrade = data.unit[who].upgrades[what]
		if not upgrade.prerequisites then return true end
		for key, level in pairs(upgrade.prerequisites) do
			if data.unit[who].upgrades[key].level < level then return false end
		end
		return true
	end

  Upgrades.unlock = function(who, what)
    local upgrade = data.unit[who].upgrades[what]
    upgrade.level = upgrade.level + 1
    table.each(ctx.units.objects, function(unit)
      if unit.class.code == who then
        f.exe(upgrade.apply, upgrade, unit)
      end
    end)
    data.unit[who].cost = data.unit[who].cost + config.biomes[ctx.biome].units.upgradeCostIncrease
    ctx.sound:play('menuHover', function(sound) sound:setVolume(2) end)
  end
end
