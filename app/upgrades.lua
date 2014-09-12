Upgrades = {}

-- TODO Player:has(Minion) etc.
local function hasVuju() return ctx.player.minions[2] == Vuju end

Upgrades.clear = function()
	Upgrades.zuju = {
		empower = {
			level = 0,
			costs = {45, 65, 95, 135, 185},
			description = 'Zuju strike with increased force.',
			values = {
				[0] = '17 - 23 damage',
				[1] = '23 - 29 damage',
				[2] = '31 - 37 damage',
				[3] = '41 - 47 damage',
				[4] = '53 - 59 damage',
				[5] = '67 - 73 damage'
			}
		},
		fortify = {
			level = 0,
			costs = {35, 60, 100, 150, 250},
			description = 'Fortify Zuju with spiritual energy, increasing their maximum health.',
			values = {
				[0] = '80 health',
				[1] = '125 health',
				[2] = '175 health',
				[3] = '235 health',
				[4] = '300 health',
				[5] = '400 health'
			}
		},
		burst = {
			level = 0,
			costs = {50, 75, 100, 125, 150},
			description = 'Zuju burst into a spirit flame on death, damaging nearby enemies.',
			values = {
				[1] = '20 damage',
				[2] = '40 damage',
				[3] = '60 damage',
				[4] = '80 damage',
				[5] = '100 damage'
			}
		},
		siphon = {
			level = 0,
			costs = {80, 160, 240},
			prerequisites = {empower = 3, fortify = 3},
			description = 'Zuju siphon life from their enemies with every strike, granting them lifesteal.',
			values = {
				[1] = '10% lifesteal',
				[2] = '20% lifesteal',
				[3] = '30% lifesteal'
			}
		},
		sanctuary = {
			level = 0,
			costs = {80, 160, 240},
			prerequisites = {fortify = 3, burst = 3},
			description = 'The spirit flame leaves behind an aura that slowly heals allies.',
			values = {
				[1] = '10 hp/s for 3 seconds.',
				[2] = '20 hp/s for 4 seconds.',
				[3] = '30 hp/s for 5 seconds.'
			}
		}
	}

	Upgrades.vuju = {
		surge = {
			level = 0,
			costs = {25, 40, 55, 70, 85},
			prerequisites = {hasVuju},
			description = 'Vuju surge with increased energy, increasing their cast range.',
			values = {
				[0] = '125 range',
				[1] = '150 range',
				[2] = '175 range',
				[3] = '200 range',
				[4] = '225 range',
				[5] = '250 range'
			}
		},
		charge = {
			level = 0,
			costs = {60, 80, 100, 120, 140},
			prerequisites = {hasVuju},
			description = 'Vuju become more charged and deal increased damage with lightning.',
			values = {
				[0] = '30 damage',
				[1] = '37 damage',
				[2] = '47 damage',
				[3] = '60 damage',
				[4] = '76 damage',
				[5] = '95 damage'
			}
		},
		condemn = {
			level = 0,
			costs = {100, 50, 50, 50, 50},
			prerequisites = {hasVuju},
			description = 'Vuju gain the ability to hex enemies, reducing the damage they deal for 5 seconds.',
			values = {
				[1] = '40% damage reduction, 8 second cooldown',
				[2] = '50% damage reduction, 7 second cooldown',
				[3] = '60% damage reduction, 6 second cooldown',
				[4] = '70% damage reduction, 5 second cooldown',
				[5] = '80% damage reduction, 4 second cooldown'
			}
		},
		arc = {
			level = 0,
			costs = {100, 200, 300},
			prerequisites = {surge = 3, charge = 3, hasVuju},
			description = 'Lightning jumps to additional nearby enemies.  Each arc deals 50% reduced damage, down to a minimum of 25% damage.',
			values = {
				[1] = '2 jumps at 50 range',
				[2] = '4 jumps at 75 range',
				[3] = '6 jumps at 100 range'
			}
		},
		soak = {
			level = 0,
			costs = {30, 60, 90},
			prerequisites = {charge = 3, condemn = 3, hasVuju},
			description = 'The curse also soaks enemies, increasing the damage they take from lightning.',
			values = {
				[1] = '33% increase',
				[2] = '67% increase',
				[3] = '100% increase'
			}
		}
	}

	Upgrades.muju = {
		flow = {
			level = 0,
			costs = {30, 50, 70, 90, 110},
			description = 'Muju channels juju more effectively, increasing the rate at which he can summon minions.',
			values = {
				[1] = '10% cooldown reduction',
				[2] = '20% cooldown reduction',
				[3] = '30% cooldown reduction',
				[4] = '40% cooldown reduction',
				[5] = '50% cooldown reduction'
			}
		},
		harvest = {
			level = 0,
			costs = {75, 150, 200},
			prerequisites = {flow = 3},
			description = 'The souls of minions are harvested after death, producing a small amount of juju.',
			values = {
				[1] = 'very juju',
				[2] = 'many points',
				[3] = 'wow'
			}
		},
		refresh = {
			level = 0,
			costs = {200},
			prerequisites = {harvest = 1},
			description = 'Muju has a chance to instantly refresh the cooldown of an ability after casting it.',
			values = {
				[1] = '15% chance'
			}
		},
		zeal = {
			level = 0,
			costs = {20, 30, 40, 50, 60},
			description = 'Muju moves more freely in the juju realm.',
			values = {
				[1] = '20% faster',
				[2] = '40% faster',
				[3] = '60% faster',
				[4] = '80% faster',
				[5] = '100% faster'
			}
		},
		absorb = {
			level = 0,
			costs = {50, 75, 100},
			prerequisites = {zeal = 3},
			description = 'Muju attracts juju towards himself while in the juju realm.  Juju magnets, how do they work?',
			values = {
				[1] = 'weak pull',
				[2] = 'average pull',
				[3] = 'strong pull'
			}
		},
		diffuse = {
			level = 0,
			costs = {200},
			prerequisites = {absorb = 1},
			description = 'Spiritual mastery of juju is attained, allowing Muju to return to his body at any point while in the juju realm.',
			values = {
				[1] = '+100% body returning-ness'
			}
		},
		imbue = {
			level = 0,
			costs = {40, 70, 100, 130, 150},
			description = 'The shrine becomes imbued with magical juju powers, allowing it to recover health over time.',
			values = {
				[1] = '0.5% max health per second',
				[2] = '1.0% max health per second',
				[3] = '1.5% max health per second',
				[4] = '2.0% max health per second',
				[5] = '2.5% max health per second'
			}
		},
		mirror = {
			level = 0,
			costs = {30, 60, 120},
			prerequisites = {imbue = 3},
			description = 'Gives the shrine a protective magic coating, reflecting a portion of damage dealt to it.',
			values = {
				[1] = '25% damage reflection',
				[2] = '50% damage reflection',
				[3] = '75% damage reflection'
			}
		},
		distort = {
			level = 0,
			costs = {200},
			prerequisites = {mirror = 1},
			description = 'While in the juju realm, the shrine slows time in the material world by 50%',
			values = {
				[1] = '1 metric flux capacitor'
			}
		}
	}

	Upgrades.makeTooltip = function(who, what)
		local pieces = {}
		local upgrade = Upgrades[who][what]
		table.insert(pieces, '{white}{title}' .. what:capitalize() .. '{normal}')
		table.insert(pieces, '{whoCares}' .. upgrade.description .. '\n')
		table.insert(pieces, '{white}{bold}Level ' .. upgrade.level .. (upgrade.values[upgrade.level] and ': ' .. upgrade.values[upgrade.level] or ''))
		if not upgrade.values[upgrade.level + 1] then
			table.insert(pieces, '{whoCares}{normal}Max Level')
		else
			table.insert(pieces, '{white}{bold}Next Level: ' .. upgrade.values[upgrade.level + 1])
			local color = ctx.player.juju >= upgrade.costs[upgrade.level + 1] and '{green}' or '{red}'
			table.insert(pieces, color .. upgrade.costs[upgrade.level + 1] .. ' juju')
			if upgrade.prerequisites then
				for name, min in pairs(upgrade.prerequisites) do
					if type(min) == 'function' then
						if min == hasVuju then
							local color = hasVuju() and '{green}' or '{red}'
							table.insert(pieces, color .. 'Requires Vuju')
						end
					else
						local color = Upgrades[who][name].level >= min and '{green}' or '{red}'
						local points = (min == 1) and 'point' or 'points'
						table.insert(pieces, color .. min .. ' ' .. points .. ' in ' .. name:capitalize())
					end
				end
			end
		end

		return table.concat(pieces, '\n')
	end

	Upgrades.canBuy = function(who, what)
		local upgrade = Upgrades[who][what]
		if not upgrade.costs[upgrade.level + 1] then return false end
		if ctx.player.juju < upgrade.costs[upgrade.level + 1] then return false end
		return Upgrades.checkPrerequisites(who, what)
	end

	Upgrades.checkPrerequisites = function(who, what)
		local upgrade = Upgrades[who][what]
		if not upgrade.prerequisites then return true end
		for key, level in pairs(upgrade.prerequisites) do
			if type(level) == 'function' then if  not level() then return false end
			elseif ctx.upgrades[who][key].level < level then return false end
		end
		return true
	end
end
