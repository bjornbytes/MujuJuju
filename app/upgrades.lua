Upgrades = {}

Upgrades.clear = function()
	Upgrades.zuju = {
		cleave = 0,
		burst = 0,
		fortify = 0
	}

	Upgrades.vuju = {
		chain = 0,
		curse = 0,
		fortify = 0
	}

	Upgrades.muju = {
		flow = 0,
		zeal = 0,
		imbue = 0
	}

	Upgrades.names = {
		zuju = {cleave = 'Cleave', burst = 'Burst', fortify = 'Fortify'},
		vuju = {chain = 'Chain', curse = 'Curse', fortify = 'Fortify'},
		muju = {flow = 'Flow', zeal = 'Zeal', imbue = 'Imbue'}
	}

	Upgrades.costs = {
		zuju = {
			cleave = {80, 100, 120},
			burst = {100, 125, 150},
			fortify = {50, 100, 150}
		},
		vuju = {
			chain = {100, 150, 200},
			curse = {60, 100, 140},
			fortify = {50, 100, 150}
		},
		muju = {
			flow = {50, 60, 70, 80, 90},
			zeal = {30, 45, 60, 75, 90},
			imbue = {40, 60, 80, 100, 120}
		}
	}

	Upgrades.keys = {
		zuju = {'cleave', 'burst', 'fortify'},
		vuju = {'chain', 'curse', 'fortify'},
		muju = {'flow', 'zeal', 'imbue'}
	}

	Upgrades.tooltips = {
		zuju = {
			cleave = {
				'Cleave\nZuju cleave enemies around their original target.\nLevel 0\nNext Level: 1 extra target\nCost: 80',
				'Cleave\nZuju damage enemies around their original target.\nLevel 1: 1 extra target\nNext Level: 2 extra targets\nCost: 100',
				'Cleave\nZuju damage enemies around their original target.\nLevel 2: 2 extra target\nNext Level: 3 extra targets\nCost: 120',
				'Cleave\nZuju damage enemies around their original target.\nLevel 3: 3 extra target\nMax Level'
			},
			burst = {
				'Burst\nZuju burst into a spirit flame on death, damaging nearby enemies.\nLevel 0\nNext Level: 20 damage, 75 radius\nCost: 100',
				'Burst\nZuju burst into a spirit flame on death, damaging nearby enemies.\nLevel 1: 20 damage, 75 radius\nNext Level: 40 damage, 125 radius\nCost: 125',
				'Burst\nZuju burst into a spirit flame on death, damaging nearby enemies.\nLevel 2: 40 damage, 125 radius\nNext Level: 60 damage, 175 radius\nCost: 150',
				'Burst\nZuju burst into a spirit flame on death, damaging nearby enemies.\nLevel 3: 60 damage, 175 radius\nMax Level'
			},
			fortify = {
				'Fortify\nImbue the Zuju with spiritual energy, increasing their maximum health.\nLevel 0\nNext Level: +50 health\nCost: 50',
				'Fortify\nImbue the Zuju with spiritual energy, increasing their maximum health.\nLevel 1: +50 health\nNext Level: +100 health\nCost: 100',
				'Fortify\nImbue the Zuju with spiritual energy, increasing their maximum health.\nLevel 2: +100 health\nNext Level: +150 health\nCost: 150',
				'Fortify\nImbue the Zuju with spiritual energy, increasing their maximum health.\nLevel 3: +150 health\nMax Level'
			}
		},
		vuju = {
			chain = {
				'Chain\nEmpower your Vuju with the two lightning bolts, increasing its damage.\nLevel 0\nNext Level: 20% to strike twice.\nCost: 100',
				'Chain\nEmpower your Vuju with the two lightning bolts, increasing its damage.\nLevel 1: 20% to strike twice.\nNext Level: 40% to strike twice.\nCost: 150',
				'Chain\nEmpower your Vuju with the two lightning bolts, increasing its damage.\nLevel 2: 40% to strike twice.\nNext Level: 60% to strike twice.\nCost: 200',
				'Chain\nEmpower your Vuju with the two lightning bolts, increasing its damage.\nLevel 3: 60% to strike twice.\nMax Level'
			},
			curse = {
				'Curse\nInfect your enemies with lightning sickness, slowing their speed.\nLevel 0\nNext Level: 20% chance to slow.\nCost: 60',
				'Curse\nInfect your enemies with lightning sickness, slowing their speed.\nLevel 1: 20% chance to slow.\nNext Level: 40% chance to slow.\nCost: 100',
				'Curse\nInfect your enemies with lightning sickness, slowing their speed.\nLevel 2: 40% chance to slow.\nNext Level: 60% chance to slow.\nCost: 140',
				'Curse\nInfect your enemies with lightning sickness, slowing their speed.\nLevel 3: 60% chance to slow.\nMax Level',
			},
			fortify = {
				'Fortify\nImbue the Vuju with spiritual energy, increasing their maximum health.\nLevel 0\nNext Level: +50 health\nCost: 50',
				'Fortify\nImbue the Vuju with spiritual energy, increasing their maximum health.\nLevel 1: +50 health\nNext Level: +100 health\nCost: 100',
				'Fortify\nImbue the Vuju with spiritual energy, increasing their maximum health.\nLevel 2: +100 health\nNext Level: +150 health\nCost: 150',
				'Fortify\nImbue the Vuju with spiritual energy, increasing their maximum health.\nLevel 3: +150 health\nMax Level',
			}
		},
		muju = {
			flow = {
				'Flow\nMuju channels juju more effectively, increasing the rate at which he can summon minions.\nLevel 0\nNext Level: 10% cooldown reduction\nCost: 50',
				'Flow\nMuju channels juju more effectively, increasing the rate at which he can summon minions.\nLevel 1: 10% cooldown reduction\nNext Level: 20% cooldown reduction\nCost: 60',
				'Flow\nMuju channels juju more effectively, increasing the rate at which he can summon minions.\nLevel 2: 20% cooldown reduction\nNext Level: 30% cooldown reduction, 10% chance to instantly refresh cooldown\nCost: 70',
				'Flow\nMuju channels juju more effectively, increasing the rate at which he can summon minions.\nLevel 3: 30% cooldown reduction, 10% chance to instantly refresh cooldown\nNext Level: 40% cooldown reduction, 10% chance to instantly refresh cooldown\nCost: 80',
				'Flow\nMuju channels juju more effectively, increasing the rate at which he can summon minions.\nLevel 4: 40% cooldown reduction, 10% chance to instantly refresh cooldown\nNext Level: 50% cooldown reduction, 10% chance to instantly refresh cooldown, 10% chance to summon an extra minion\nCost: 90',
				'Flow\nMuju channels juju more effectively, increasing the rate at which he can summon minions.\nLevel 5: 50% cooldown reduction, 10% chance to instantly refresh cooldown, 10% chance to summon an extra minion\nMax Level'
			},
			zeal = {
				'Zeal\nMuju moves more freely in the juju realm.\nLevel 0\nNext Level: 20% faster\nCost: 30',
				'Zeal\nMuju moves more freely in the juju realm.\nLevel 1: 20% faster\nNext Level: 40% faster\nCost: 45',
				'Zeal\nMuju moves more freely in the juju realm.\nLevel 2: 40% faster\nNext Level: 60% faster, juju magnet\nCost: 60',
				'Zeal\nMuju moves more freely in the juju realm.\nLevel 3: 60% faster, juju magnet\nNext Level: 80% faster, juju magnet\nCost: 75',
				'Zeal\nMuju moves more freely in the juju realm.\nLevel 4: 80% faster, juju magnet\nNext Level: 100% faster, juju magnet, ability to return to your body\nCost: 75',
				'Zeal\nMuju moves more freely in the juju realm.\nLevel 5: 100% faster, juju magnet, ability to return to your body\nMax Level',
			},
			imbue = {
				'Imbue\nThe shrine becomes imbued with magical juju powers, allowing it to recover health over time.\nLevel 0\nNext Level: .5% max health per second\nCost: 40',
				'Imbue\nThe shrine becomes imbued with magical juju powers, allowing it to recover health over time.\nLevel 1: .5% max health per second\nNext Level: 1.0% max health per second\nCost: 60',
				'Imbue\nThe shrine becomes imbued with magical juju powers, allowing it to recover health over time.\nLevel 2: 1.0% max health per second\nNext Level: 1.5% max health per second, reflects 50% damage\nCost: 80',
				'Imbue\nThe shrine becomes imbued with magical juju powers, allowing it to recover health over time.\nLevel 3: 1.5% max health per second, reflects 50% damage\nNext Level: 2.0% max health per second, reflects 50% damage\nCost: 100',
				'Imbue\nThe shrine becomes imbued with magical juju powers, allowing it to recover health over time.\nLevel 4: 2.0% max health per second, reflects 50% damage\nNext Level: 2.5% max health per second, reflects 50% damage, slows enemies approaching the shrine.\nCost: 120',
				'Imbue\nThe shrine becomes imbued with magical juju powers, allowing it to recover health over time.\nLevel 5: 2.5% max health per second, reflects 50% damage, slows enemies approaching the shrine\nMax Level',
			}
		},
	}
end
