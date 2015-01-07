return {

  starters = {
    'bruju',
    'thuju'
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
    baseCooldown = 3,
    minCooldown = .5,
    globalCooldown = 1.5,
    baseJuju = 30,
    jujuRate = 1,
    basePopulation = 3,
    maxPopulation = 10
  },

  shruju = {
    growTime = 60,
    minGrowTime = 10,
    harvestCooldownReduction = 5,
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
        silver = 'cavern',
        gold = 'unit'
      },
      juju = {
        minimum = {
          base = 14,
          exponent = .8,
          coefficient = .75
        },
        maximum = {
          base = 20,
          exponent = .85,
          coefficient = 1
        }
      },
      units = {
        minEnemyRate = 12,
        maxEnemyRate = 16,
        maxEnemiesCoefficient = .4,
        levelScale = 1,
        upgradeCostIncrease = 2,
        maxElites = 1,
        thresholds = {
          duju = 0,
          spuju = 180,
          kuju = 600
        }
      },
      shrujuPatches = {
        [1] = {
          minTimer = 30,
          maxTimer = 40
        },
        [2] = {
          minTimer = 300,
          maxTimer = 400
        }
      },
      runes = {
        maxLevel = 25,
        specialChance = .01
      },
      effects = {
        vignette = {
          blur = {.45, 1.15},
          radius = {.85, .85}
        },
        bloom = {
          alpha = {10, 70}
        }
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
        silver = 'tundra'
      },
      juju = {
        minimum = {
          base = 14,
          exponent = .8,
          coefficient = .75
        },
        maximum = {
          base = 20,
          exponent = .85,
          coefficient = 1
        }
      },
      units = {
        minEnemyRate = 6,
        maxEnemyRate = 9,
        maxEnemiesCoefficient = .5,
        levelScale = 1.25,
        upgradeCostIncrease = 3,
        maxElites = 1,
        thresholds = {
          spuju = 0,
          duju = 300,
          kuju = 300
        }
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
      },
      effects = {
        vignette = {
          blur = {.6, 1.15},
          radius = {.75, .75}
        },
        bloom = {
          alpha = {5, 20}
        }
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
          base = 14,
          exponent = .8,
          coefficient = .75
        },
        maximum = {
          base = 20,
          exponent = .85,
          coefficient = 1
        }
      },
      units = {
        minEnemyRate = 6,
        maxEnemyRate = 9,
        maxEnemiesCoefficient = .6,
        levelScale = 1.5,
        upgradeCostIncrease = 4,
        maxElites = 2,
        thresholds = {
          kuju = 0,
          spuju = 600,
          duju = 600
        }
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
      },
      effects = {
        vignette = {
          blur = {.45, 1.15},
          radius = {.85, .85}
        },
        bloom = {
          alpha = {10, 20}
        }
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
          base = 14,
          exponent = .8,
          coefficient = .75
        },
        maximum = {
          base = 20,
          exponent = .85,
          coefficient = 1
        }
      },
      units = {
        minEnemyRate = 6,
        maxEnemyRate = 8,
        maxEnemiesCoefficient = .7,
        levelScale = 2,
        upgradeCostIncrease = 5,
        maxElites = 3,
        thresholds = {
          kuju = 0,
          spuju = 0,
          duju = 0
        }
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
      },
      effects = {
        vignette = {
          blur = {.45, 1.15},
          radius = {.85, .85}
        },
        bloom = {
          alpha = {10, 70}
        }
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
      purple = {100, 0, 200},
      green = {100, 200, 100},
      blue = {100, 100, 200},
      red = {200, 100, 100}
    }
  },

  units = {
    baseHealthScaling = 3,
    baseDamageScaling = 3
  },

  defaultUser = {
    minions = {},
    runes = {},
    deck = {minions = {}, runes = {}},
    biomes = {'forest'},
    highscores = {forest = 0, cavern = 0, tundra = 0, volcano = 0}
  }
}
