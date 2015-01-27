return {

  starters = {
    'bruju',
    'thuju',
    'buju'
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

  attributes = {
    list = {'vitality', 'strength', 'agility', 'flow'},
    vitality = {
      health = 10
    },
    strength = {
      damage = 3
    },
    agility = {
      speed = 3,
      attackSpeed = .03
    },
    flow = {
      cooldownSpeed = .03,
      spellPower = 5
    }
  },

  elites = {
    baseModifier = .005,
    levelModifier = .0015,
    jujuModifier = 2,
    minimumLevel = 20,
    scale = 1.25,
    healthModifier = 6,
    damageModifier = 1.5,
    buffs = {
      sinister = {
        damageModifier = 1.75
      },
      chilling = {
        exhaust = .65,
        slow = .65,
        duration = 1
      },
      parasitic = {
        lifesteal = .5
      },
      spined = {
        reflect = 1
      },
      venomous = {
        dotModifier = .35,
        dotTimer = 3
      },
      hulking = {
        healthModifier = 2.5,
        slow = .5
      },
      demolisher = {
        damageModifier = 5
      }
    }
  },

  player = {
    baseCooldown = 5,
    minCooldown = .75,
    globalCooldown = 3,
    baseJuju = 30,
    jujuRate = 1,
    basePopulation = 1,
    maxPopulation = 10,
    colors = {
      purple = {.5, 0, 1},
      red = {1, 0, 0},
      blue = {0, 0, 1},
      green = {0, 1, 0},
      black = {0, 0, 0},
      white = {1, 1, 1}
    },
    colorOrder = {'purple', 'red', 'blue', 'green', 'black', 'white'}
  },

  shruju = {
    growTime = 60,
    minGrowTime = 20,
    harvestCooldownReduction = 4,
    magicDuration = 90
  },

  biomes = {

    forest = {
      name = 'The Overgrowth',
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
          base = 20,
          exponent = .7,
          coefficient = 1
        },
        maximum = {
          base = 25,
          exponent = .7,
          coefficient = 1.2
        }
      },
      units = {
        minEnemyRate = 14,
        maxEnemyRate = 17,
        minEnemyRateDecay = .05,
        maxEnemyRateDecay = .05,
        maxEnemiesCoefficient = .2,
        levelScale = .75,
        upgradeCostIncrease = 1,
        maxElites = 1,
        thresholds = {
          duju = 0,
          spuju = 500,
          kuju = 720
        }
      },
      shrujuPatches = {1, 450},
      runes = {
        maxLevel = 25,
        specialChance = .1
      },
      effects = {
        vignette = {
          blur = {.45, 1.15},
          radius = {.85, .85}
        },
        bloom = {
          alpha = {10, 50}
        }
      }
    },

    cavern = {
      name = 'The Hollow',
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
          base = 20,
          exponent = .7,
          coefficient = 1
        },
        maximum = {
          base = 25,
          exponent = .7,
          coefficient = 1.2
        }
      },
      units = {
        minEnemyRate = 11,
        maxEnemyRate = 13,
        minEnemyRateDecay = .11,
        maxEnemyRateDecay = .11,
        maxEnemiesCoefficient = .2,
        levelScale = .85,
        upgradeCostIncrease = 1,
        maxElites = 1,
        thresholds = {
          spuju = 0,
          duju = 1100,
          kuju = 1300
        }
      },
      shrujuPatches = {},
      runes = {
        maxLevel = 25,
        specialChance = .1
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
      name = 'The Wild North',
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
          base = 20,
          exponent = .7,
          coefficient = 1
        },
        maximum = {
          base = 25,
          exponent = .7,
          coefficient = 1.2
        }
      },
      units = {
        minEnemyRate = 9,
        maxEnemyRate = 11,
        minEnemyRateDecay = .11,
        maxEnemyRateDecay = .11,
        maxEnemiesCoefficient = .2,
        levelScale = .95,
        upgradeCostIncrease = 1,
        maxElites = 2,
        thresholds = {
          kuju = 0,
          spuju = 2100,
          duju = 2400
        }
      },
      shrujuPatches = {},
      runes = {
        maxLevel = 75,
        specialChance = .1
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
      name = 'The Cinders',
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
          base = 20,
          exponent = .7,
          coefficient = 1
        },
        maximum = {
          base = 25,
          exponent = .7,
          coefficient = 1.2
        }
      },
      units = {
        minEnemyRate = 7,
        maxEnemyRate = 9,
        minEnemyRateDecay = .11,
        maxEnemyRateDecay = .11,
        maxEnemiesCoefficient = .2,
        levelScale = 1.05,
        upgradeCostIncrease = 1,
        maxElites = 3,
        thresholds = {
          kuju = 0,
          spuju = 0,
          duju = 0
        }
      },
      shrujuPatches = {},
      runes = {
        maxLevel = 100,
        specialChance = .1
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
    stats = {'health', 'damage', 'speed'},
    health = {
      names = {'Rune of Fortitude', 'Rune of Vitality', 'Rune of Stamina', 'Rune of the Soul'},
      flatRange = {10, 250},
      scalingRange = {1, 25}
    },
    damage = {
      names = {'Rune of Might', 'Rune of Force', 'Rune of Ruin', 'Rune of Power'},
      flatRange = {3, 70},
      scalingRange = {1, 8}
    },
    speed = {
      names = {'Rune of Agility', 'Rune of Haste', 'Rune of Swiftness', 'Rune of the Wind'},
      flatRange = {5, 80},
      scalingRange = {1, 8}
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
      red = {230, 92, 92},
      orange = {230, 161, 92},
      yellow = {230, 230, 92},
      green = {161, 230, 92},
      lime = {92, 230, 92},
      aqua = {92, 230, 161},
      cyan = {92, 230, 230},
      blue = {92, 161, 230},
      indigo = {92, 92, 230},
      purple= {161, 92, 230},
      magenta = {230, 92, 230},
      pink = {230, 92, 161}
    },
    imageCount = 9
  },

  units = {
    baseHealthScaling = 3,
    baseDamageScaling = 3
  },

  defaultUser = {
    minions = {'thuju', 'bruju', 'buju'},
    runes = {},
    deck = {minions = {}, runes = {}},
    deckSlots = 1,
    biomes = {'forest'},
    highscores = {forest = 0, cavern = 0, tundra = 0, volcano = 0},
    name = 'Muju',
    color = 'purple'
  }
}
