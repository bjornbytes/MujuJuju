return {
  minions = {'bruju', 'thuju', 'kuju'},
  elites = {
    baseModifier = .005,
    levelModifier = .0015,
    scale = 1.5,
    minimumLevel = 5,
    buffs = {
      sinister = {
        damageModifier = 10
      },
      chilling = {
        exhaust = .3,
        slow = .3
      },
      parasitic = {
        lifesteal = .5
      },
      spined = {
        reflect = 1 
      },
      venomous = {
        dotModifier = .75,
        dotTimer = 3
      },
      hulking = {
        healthModifier = 3,
        slow = .5
      },
      pure = {}
    }
  },
  biomeOrder = {'forest', 'tundra', 'volcano'},
  biomes = {
    forest = {
      name = 'Forest',
      benchmarks = {
        bronze = 300,
        silver = 900,
        gold = 1800
      },
      rewards = {
        silver = 'tundra',
        gold = 'thuju'
      }
    },
    tundra = {
      name = 'Tundra',
      benchmarks = {
        bronze = 300,
        silver = 500,
        gold = 1000
      },
      rewards = {
        silver = 'volcano',
        gold = 'kuju'
      }
    },
    volcano = {
      name = 'Volcano',
      benchmarks = {
        bronze = 200,
        silver = 400,
        gold = 600
      },
      rewards = {
        gold = 'bruju'
      }
    }
  },
  units = {
    forest = {
      minEnemyRate = 6,
      maxEnemyRate = 9,
      levelScale = 1
    },
    tundra = {
      minEnemyRate = 5,
      maxEnemyRate = 7,
      levelScale = 1.5
    },
    volcano = {
      minEnemyRate = 4,
      maxEnemyRate = 5,
      levelScale = 2
    }
  },
  shrujuPatches = {
    forest = {
      [1] = {
        minTimer = 30,
        maxTimer = 40
      },
      [2] = {
        minTimer = 120,
        maxTimer = 130
      }
    },
    tundra = {
      [1] = {
        minTimer = 30,
        maxTimer = 40
      },
      [2] = {
        minTimer = 120,
        maxTimer = 130
      }
    },
    volcano = {
      [1] = {
        minTimer = 30,
        maxTimer = 40
      },
      [2] = {
        minTimer = 120,
        maxTimer = 130
      }
    }
  },
  defaultUser = {
    deck = {},
    biomes = {'forest'},
    highscores = {forest = 0, tundra = 0, volcano = 0}
  }
}
