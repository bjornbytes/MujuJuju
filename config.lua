return {

  starters = {
    'bruju',
    'thuju',
    'kuju'
  },

  biomeOrder = {
    'forest',
    'tundra',
    'volcano'
  },

  elites = {
    baseModifier = .005,
    levelModifier = .0015,
    jujuModifier = 2,
    minimumLevel = 5,
    scale = 1.5,
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
      },
      juju = {
        minimum = {
          base = 8,
          exponent = .8,
          coefficient = .75
        },
        maximum = {
          base = 12,
          exponent = .85,
          coefficient = 1
        }
      },
      units = {
        minEnemyRate = 6,
        maxEnemyRate = 9,
        levelScale = 1,
        upgradeCostIncrease = 1,
      },
      shrujuPatches = {
        [1] = {
          minTimer = 1,
          maxTimer = 2
        },
        [2] = {
          minTimer = 120,
          maxTimer = 130
        }
      },
      runes = {
        maxLevel = 25,
        specialChance = .01
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
      },
      juju = {
        minimum = {
          base = 8,
          exponent = .8,
          coefficient = .75
        },
        maximum = {
          base = 12,
          exponent = .85,
          coefficient = 1
        }
      },
      units = {
        minEnemyRate = 5,
        maxEnemyRate = 7,
        levelScale = 1.5,
        upgradeCostIncrease = 2
      },
      shrujuPatches = {
        [1] = {
          minTimer = 30,
          maxTimer = 40
        },
        [2] = {
          minTimer = 120,
          maxTimer = 130
        }
      },
      runes = {
        maxLevel = 50,
        specialChance = .04
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
        gold = 'bruju',
      },
      juju = {
        minimum = {
          base = 8,
          exponent = .8,
          coefficient = .75
        },
        maximum = {
          base = 12,
          exponent = .85,
          coefficient = 1
        }
      },
      units = {
        minEnemyRate = 4,
        maxEnemyRate = 5,
        levelScale = 2,
        upgradeCostIncrease = 3
      },
      shrujuPatches = {
        [1] = {
          minTimer = 30,
          maxTimer = 40
        },
        [2] = {
          minTimer = 120,
          maxTimer = 130
        }
      },
      runes = {
        maxLevel = 100,
        specialChance = .08
      }
    }
  },

  runes = {
    health = {
      name = 'Rune of Fortitude',
      flatRange = {10, 250},
      scalingRange = {2, 25}
    },
    damage = {
      name = 'Rune of Might',
      flatRange = {3, 80},
      scalingRange = {1, 15}
    },
    speed = {
      name = 'Rune of Agility',
      flatRange = {5, 80},
      scalingRange = {1, 5}
    }
  },

  defaultUser = {
    deck = {minions = {}, runes = {}},
    biomes = {'forest'},
    highscores = {forest = 0, tundra = 0, volcano = 0}
  }
}
