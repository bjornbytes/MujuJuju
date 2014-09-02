Upgrades = {}

Upgrades.clear = function()
	Upgrades.zuju = {
		cleave = 0,
		fortify = 0,
		burst = 0
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
		zuju = {cleave = 'Cleave', fortify = 'Fortify', burst = 'Burst'},
		vuju = {chain = 'Chain', curse = 'Curse', fortify = 'Fortify'},
		muju = {flow = 'Flow', zeal = 'Zeal', imbue = 'Imbue'}
	}

	Upgrades.costs = {
		zuju = {
			cleave = {45, 65, 95, 135, 185},
			fortify = {35, 60, 100, 150, 250},
			burst = {100, 125, 150}
		},
		vuju = {
			chain = {100, 150, 200},
			curse = {60, 100, 140},
			fortify = {50, 100, 150}
		},
		muju = {
			flow = {30, 50, 70, 90, 110},
			zeal = {30, 65, 100, 135, 170},
			imbue = {40, 70, 100, 130, 150}
		}
	}

	Upgrades.keys = {
		zuju = {'cleave', 'fortify', 'burst'},
		vuju = {'chain', 'curse', 'fortify'},
		muju = {'flow', 'zeal', 'imbue'}
	}

	Upgrades.tooltips = {
		zuju = {
			cleave = {
				'Cleave\nZuju strike with increased strength.\nLevel 0: 17 - 23 damage\nNext Level: 23 - 29 damage\nCost: 45',
				'Cleave\nZuju strike with increased strength.\nLevel 1: 23 - 29 damage\nNext Level: 31 - 37 damage\nCost: 65',
				'Cleave\nZuju strike with increased strength.\nLevel 2: 31 - 37 damage\nNext Level: 41 - 47 damage, 5% chance to critically strike\nCost: 95',
				'Cleave\nZuju strike with increased strength.\nLevel 3: 41 - 47 damage, 5% chance to critically strike\nNext Level: 53 - 59 damage, 5% chance to critically strike\nCost: 135',
				'Cleave\nZuju strike with increased strength.\nLevel 4: 53 - 59 damage, 5% chance to critically strike\nNext Level: 67 - 73 damage, 10% chance to critically strike\nCost: 185',
				'Cleave\nZuju strike with increased strength.\nLevel 5: 67 - 73 damage, 10% chance to critically strike\nMax Level'
			},
			fortify = {
				'Fortify\nImbue the Zuju with spiritual energy, increasing their maximum health.\nLevel 0: 80 health\nNext Level: 125 health\nCost: 35',
				'Fortify\nImbue the Zuju with spiritual energy, increasing their maximum health.\nLevel 1: 125 health\nNext Level: 175 health\nCost: 60',
				'Fortify\nImbue the Zuju with spiritual energy, increasing their maximum health.\nLevel 2: 175 health\nNext Level: 235 health\nCost: 100',
				'Fortify\nImbue the Zuju with spiritual energy, increasing their maximum health.\nLevel 3: 235 health\nNext Level: 300 health\nCost: 150',
				'Fortify\nImbue the Zuju with spiritual energy, increasing their maximum health.\nLevel 4: 300 health\nNext Level: 400 health\nCost: 250',
				'Fortify\nImbue the Zuju with spiritual energy, increasing their maximum health.\nLevel 5: 400 health\nMax Level'
			},
			burst = {
				'Burst\nZuju burst into a spirit flame on death, damaging nearby enemies.\nLevel 0\nNext Level: 20 damage, 75 radius\nCost: 100',
				'Burst\nZuju burst into a spirit flame on death, damaging nearby enemies.\nLevel 1: 20 damage, 75 radius\nNext Level: 40 damage, 125 radius\nCost: 125',
				'Burst\nZuju burst into a spirit flame on death, damaging nearby enemies.\nLevel 2: 40 damage, 125 radius\nNext Level: 60 damage, 175 radius\nCost: 150',
				'Burst\nZuju burst into a spirit flame on death, damaging nearby enemies.\nLevel 3: 60 damage, 175 radius\nMax Level'
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
				'Flow\nMuju channels juju more effectively, increasing the rate at which he can summon minions.\nLevel 0\nNext Level: 10% cooldown reduction\nCost: 30',
				'Flow\nMuju channels juju more effectively, increasing the rate at which he can summon minions.\nLevel 1: 10% cooldown reduction\nNext Level: 20% cooldown reduction\nCost: 50',
				'Flow\nMuju channels juju more effectively, increasing the rate at which he can summon minions.\nLevel 2: 20% cooldown reduction\nNext Level: 30% cooldown reduction, 10% chance to instantly refresh cooldown\nCost: 70',
				'Flow\nMuju channels juju more effectively, increasing the rate at which he can summon minions.\nLevel 3: 30% cooldown reduction, 10% chance to instantly refresh cooldown\nNext Level: 40% cooldown reduction, 10% chance to instantly refresh cooldown\nCost: 70',
				'Flow\nMuju channels juju more effectively, increasing the rate at which he can summon minions.\nLevel 4: 40% cooldown reduction, 10% chance to instantly refresh cooldown\nNext Level: 50% cooldown reduction, 10% chance to instantly refresh cooldown, 10% chance to summon an extra minion\nCost: 110',
				'Flow\nMuju channels juju more effectively, increasing the rate at which he can summon minions.\nLevel 5: 50% cooldown reduction, 10% chance to instantly refresh cooldown, 10% chance to summon an extra minion\nMax Level'
			},
			zeal = {
				'Zeal\nMuju moves more freely in the juju realm.\nLevel 0\nNext Level: 20% faster\nCost: 30',
				'Zeal\nMuju moves more freely in the juju realm.\nLevel 1: 20% faster\nNext Level: 40% faster\nCost: 65',
				'Zeal\nMuju moves more freely in the juju realm.\nLevel 2: 40% faster\nNext Level: 60% faster, juju magnet\nCost: 100',
				'Zeal\nMuju moves more freely in the juju realm.\nLevel 3: 60% faster, juju magnet\nNext Level: 80% faster, juju magnet\nCost: 135',
				'Zeal\nMuju moves more freely in the juju realm.\nLevel 4: 80% faster, juju magnet\nNext Level: 100% faster, juju magnet, ability to return to your body\nCost: 170',
				'Zeal\nMuju moves more freely in the juju realm.\nLevel 5: 100% faster, juju magnet, ability to return to your body\nMax Level',
			},
			imbue = {
				'Imbue\nThe shrine becomes imbued with magical juju powers, allowing it to recover health over time.\nLevel 0\nNext Level: .5% max health per second\nCost: 40',
				'Imbue\nThe shrine becomes imbued with magical juju powers, allowing it to recover health over time.\nLevel 1: .5% max health per second\nNext Level: 1.0% max health per second\nCost: 70',
				'Imbue\nThe shrine becomes imbued with magical juju powers, allowing it to recover health over time.\nLevel 2: 1.0% max health per second\nNext Level: 1.5% max health per second, reflects 50% damage\nCost: 100',
				'Imbue\nThe shrine becomes imbued with magical juju powers, allowing it to recover health over time.\nLevel 3: 1.5% max health per second, reflects 50% damage\nNext Level: 2.0% max health per second, reflects 50% damage\nCost: 130',
				'Imbue\nThe shrine becomes imbued with magical juju powers, allowing it to recover health over time.\nLevel 4: 2.0% max health per second, reflects 50% damage\nNext Level: 2.5% max health per second, reflects 50% damage, slows enemies approaching the shrine.\nCost: 170',
				'Imbue\nThe shrine becomes imbued with magical juju powers, allowing it to recover health over time.\nLevel 5: 2.5% max health per second, reflects 50% damage, slows enemies approaching the shrine\nMax Level',
			}
		},
	}
end
