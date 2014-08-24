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
			}
		}
	}
end
