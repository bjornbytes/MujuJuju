Upgrades = {}

Upgrades.clear = function()
	Upgrades.canBuy = function(who, what)
    local p = ctx.player
		local upgrade = data.unit[who].upgrades[what]
    if upgrade.level >= upgrade.maxLevel then return false end
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
    data.unit[who].cost = data.unit[who].cost + config.units.upgradeCostIncrease
  end

  Upgrades.canBuyAttribute = function(who, what)
    local unit = data.unit[who]
    local p = ctx.player
    return p.juju >= unit.attributeCosts[what]
  end

  Upgrades.unlockAttribute = function(who, what)
    local unit = data.unit[who]
    unit.attributes[what] = unit.attributes[what] + 1
    unit.attributeCosts[what] = unit.attributeCosts[what] + config.attributes.costIncrease
    unit.cost = unit.cost + config.units.attributeCostIncrease
  end
end
