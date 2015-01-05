Upgrades = {}

Upgrades.clear = function()
	Upgrades.makeTooltip = function(who, what)
    local p = ctx.players:get(ctx.id)
		local pieces = {}
		local upgrade = data.unit[who].upgrades[what]
		table.insert(pieces, '{white}{title}' .. upgrade.name .. '{normal}')
		table.insert(pieces, '{whoCares}' .. upgrade.description .. '\n')
		table.insert(pieces, '{white}{bold}Level ' .. upgrade.level .. (upgrade.values[upgrade.level] and ': ' .. upgrade.values[upgrade.level] or ''))
		if not upgrade.values[upgrade.level + 1] then
			table.insert(pieces, '{whoCares}{normal}Max Level')
		else
			table.insert(pieces, '{white}{bold}Next Level: ' .. upgrade.values[upgrade.level + 1])
			local color = p.juju >= upgrade.costs[upgrade.level + 1] and '{green}' or '{red}'
			table.insert(pieces, color .. upgrade.costs[upgrade.level + 1] .. ' juju')
			if upgrade.prerequisites then
				for name, min in pairs(upgrade.prerequisites) do
          local color = data.unit[who].upgrades[name].level >= min and '{green}' or '{red}'
          local points = (min == 1) and 'point' or 'points'
          table.insert(pieces, color .. min .. ' ' .. points .. ' in ' .. name:capitalize())
				end
			end
		end

		return table.concat(pieces, '\n')
	end

	Upgrades.canBuy = function(who, what)
    local p = ctx.players:get(ctx.id)
		local upgrade = data.unit[who].upgrades[what]
		if not upgrade.costs[upgrade.level + 1] then return false end
		if p.juju < upgrade.costs[upgrade.level + 1] then return false end
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
    ctx.sound:play({sound = 'menuClick'})
  end
end
