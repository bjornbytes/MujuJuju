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
		warp = 0,
		harvest = 0,
		magnet = 0
	}

	Upgrades.names = {
		zuju = {cleave = 'Cleave', burst = 'Burst', fortify = 'Fortify'},
		vuju = {chain = 'Chain', curse = 'Curse', fortify = 'Fortify'},
		muju = {warp = 'Warp', harvest = 'Harvest', magnet = 'Magnet'}
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
			warp = {200, 400, 600},
			harvest = {500, 500, 500},
			magnet = {200, 300, 400}
		}
	}

	Upgrades.keys = {
		zuju = {'cleave', 'burst', 'fortify'},
		vuju = {'chain', 'curse', 'fortify'},
		muju = {'warp', 'harvest', 'magnet'}
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
				'Burst\nZuju burst into a spirit flame on death, damaging nearby enemies.\nLevel 0\nNext Level: 30 damage, 100 radius\nCost: 100',
				'Burst\nZuju burst into a spirit flame on death, damaging nearby enemies.\nLevel 1: 30 damage, 100 radius\nNext Level: 60 damage, 200 radius\nCost: 125',
				'Burst\nZuju burst into a spirit flame on death, damaging nearby enemies.\nLevel 2: 60 damage, 200 radius\nNext Level: 90 damage, 300 radius\nCost: 150',
				'Burst\nZuju burst into a spirit flame on death, damaging nearby enemies.\nLevel 3: 90 damage, 300 radius\nMax Level'
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
			warp = {
				'Warp\nMuju distorts time around him while in the Juju realm, slowing time in the material realm.\nLevel 0\nNext Level: 50% slow\nCost: 200',
				'Warp\nMuju distorts time around him while in the Juju realm, slowing time in the material realm.\nLevel 1: 50% slow\nNext Level: 67% slow\nCost: 400',
				'Warp\nMuju distorts time around him while in the Juju realm, slowing time in the material realm.\nLevel 2: 67% slow\nNext Level: 75% slow\nCost: 600',
				'Warp\nMuju distorts time around him while in the Juju realm, slowing time in the material realm.\nLevel 3: 75% slow\nMax Level',
			},
			harvest = {
				'Harvest\nMuju taps into his Juju powers, allowing him to harvest Juju from Zuju and Vuju.\nLevel 0\nNext Level: Very Muju\nCost: 500',
				'Harvest\nMuju taps into his Juju powers, allowing him to harvest Juju from Zuju and Vuju.\nLevel 1: Very Juju\nNext Level: Many Juju\nCost: 500',
				'Harvest\nMuju taps into his Juju powers, allowing him to harvest Juju from Zuju and Vuju.\nLevel 2: Many Juju\nNext Level: Wow\nCost: 500',
				'Harvest\nMuju taps into his Juju powers, allowing him to harvest Juju from Zuju and Vuju.\nLevel 3: Wow\nMax Level',
			},
			magnet = {
				'Juju Magnet\nMuju uses his Juju powers to attract Juju to himself while in the Juju realm.  Juju magnets, how do they work?\nLevel 0\nNext Level: Weak Magnet\nCost: 200',
				'Juju Magnet\nMuju uses his Juju powers to attract Juju to himself while in the Juju realm.  Juju magnets, how do they work?\nLevel 1: Weak Magnet\nNext Level: Strong Magnet\nCost: 300',
				'Juju Magnet\nMuju uses his Juju powers to attract Juju to himself while in the Juju realm.  Juju magnets, how do they work?\nLevel 2: Strong Magnet\nNext Level: Superconductor Plasma Space-time Continuum Magnet\nCost: 400',
				'Juju Magnet\nMuju uses his Juju powers to attract Juju to himself while in the Juju realm.  Juju magnets, how do they work?\nLevel 3: Superconductor Plasma Space-time Continuum Magnet\nMax Level',
			}
		},
	}
end
