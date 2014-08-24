Upgrades = {}

Upgrades.clear = function()
	Upgrades.zuju = {
		cleave = 0,
		burst = 0,
		fortify = 0
	}

	Upgrades.vuju = {
		unlock = 0,
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
		vuju = {unlock = 'Unlock', chain = 'Chain', curse = 'Curse', fortify = 'Fortify'},
		muju = {warp = 'Warp', harvest = 'Harvest', magnet = 'Magnet'}
	}

	Upgrades.costs = {
		zuju = {
			cleave = {80, 100, 120},
			burst = {100, 125, 150},
			fortify = {50, 100, 150}
		},
		vuju = {
			unlock = {200},
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
		vuju = {'unlock', 'chain', 'curse', 'fortify'},
		muju = {'warp', 'harvest', 'magnet'}
	}
end
