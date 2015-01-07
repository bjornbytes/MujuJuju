return {

  starters = {
    'bruju',
    'thuju',
    'kuju'
  },

  enemies = {
    'duju',
    'spuju',
    'kuju'
  },

  biomeOrder = {
    'forest',
    'cavern',
    'tundra',
    'volcano'
  },

  elites = {
    baseModifier = .005,
    levelModifier = .0015,
    jujuModifier = 2,
    minimumLevel = 20,
    scale = 1.35,
    healthModifier = 2,
    damageModifier = 1.5,
    buffs = {
      sinister = {
        damageModifier = 2
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

  player = {
    baseCooldown = .3,
    minCooldown = .5,
    globalCooldown = 1.5,
    baseJuju = 3000,
    jujuRate = 1,
    basePopulation = 30,
    maxPopulation = 10
  },

  shruju = {
    growTime = 60,
    minGrowTime = 10,
    harvestCooldownReduction = 6,
    magicDuration = 90
  },

  biomes = {

    forest = {
      name = 'The Forest',
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
          base = 10,
          exponent = .85,
          coefficient = .75
        },
        maximum = {
          base = 15,
          exponent = .85,
          coefficient = 1
        }
      },
      units = {
        minEnemyRate = 8,
        maxEnemyRate = 12,
        levelScale = 1,
        upgradeCostIncrease = 1,
        maxElites = 1
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
        maxLevel = 25,
        specialChance = .01
      }
    },

    cavern = {
      name = 'The Cavern',
      benchmarks = {
        bronze = 300,
        silver = 900,
        gold = 1800
      },
      rewards = {
        silver = 'tundra',
        gold = 'bruju'
      },
      juju = {
        minimum = {
          base = 10,
          exponent = .85,
          coefficient = .75
        },
        maximum = {
          base = 15,
          exponent = .85,
          coefficient = 1
        }
      },
      units = {
        minEnemyRate = 6,
        maxEnemyRate = 9,
        levelScale = 1.25,
        upgradeCostIncrease = 2,
        maxElites = 1
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
        silver = 'volcano'
      },
      juju = {
        minimum = {
          base = 10,
          exponent = .85,
          coefficient = .75
        },
        maximum = {
          base = 15,
          exponent = .85,
          coefficient = 1
        }
      },
      units = {
        minEnemyRate = 6,
        maxEnemyRate = 9,
        levelScale = 1.5,
        upgradeCostIncrease = 3,
        maxElites = 2
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
        maxLevel = 75,
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
        --
      },
      juju = {
        minimum = {
          base = 10,
          exponent = .85,
          coefficient = .75
        },
        maximum = {
          base = 15,
          exponent = .85,
          coefficient = 1
        }
      },
      units = {
        minEnemyRate = 6,
        maxEnemyRate = 8,
        levelScale = 2,
        upgradeCostIncrease = 4,
        maxElites = 3
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
      names = {'Rune of Fortitude', 'Rune of Vitality', 'Rune of Stamina', 'Rune of the Soul'},
      flatRange = {10, 250},
      scalingRange = {2, 25}
    },
    damage = {
      names = {'Rune of Might', 'Rune of Force', 'Rune of Ruin', 'Rune of Power'},
      flatRange = {3, 80},
      scalingRange = {1, 15}
    },
    speed = {
      names = {'Rune of Agility', 'Rune of Haste', 'Rune of Swiftness', 'Rune of the Wind'},
      flatRange = {5, 80},
      scalingRange = {1, 5}
    },
    prefixes = {
      'Broken',
      'Unpolished',
      'Damaged',
      'Scratched',
      'Lost',
      'Lesser',
      'Ordinary',
      'Prosaic',
      'Common',
      'Uncommon',
      'Greater',
      'Polished',
      'Adept',
      'Godly',
      'Exquisite',
      'Grand',
      'Legendary'
    },
    colors = {
      purple = {255, 255, 255}
    }
  },

  defaultUser = {
    minions = {},
    runes = {},
    deck = {minions = {}, runes = {}},
    biomes = {'forest'},
    highscores = {forest = 0, cavern = 0, tundra = 0, volcano = 0}
  }
}
