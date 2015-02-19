return {

  starters = {
    'bruju',
    'thuju',
    'buju',
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
      haste = .03,
      spirit = 5
    }
  },

  elites = {
    baseModifier = .005,
    levelModifier = .0015,
    jujuModifier = 2,
    minimumLevel = 20,
    scale = 1.25,
    healthModifier = 9,
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
      },
      rallying = {
        range = 100,
        damageModifier = 4
      },
      frenzied = {
        frenzy = 1,
        haste = 1,
        healthModified = 7
      },
      pummeling = {
        offset = 100
      },
      cursed = {
        range = 100,
        weakenModifier = .2
      }
    }
  },

  player = {
    baseCooldown = 5,
    minCooldown = .75,
    globalCooldown = 3,
    baseJuju = 30,
    jujuRate = 0,
    basePopulation = 3,
    maxPopulation = 10,
    startingLives = 3,
    livesPerLevel = 3,
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
        minEnemyRate = 10,
        maxEnemyRate = 12,
        minEnemyRateDecay = .08,
        maxEnemyRateDecay = .08,
        maxEnemiesCoefficient = .2,
        levelScale = .75,
        upgradeCostIncrease = 1,
        maxElites = 1,
        eliteBuffCount = 1,
        types = {
          duju = 0,
          spuju = 600
        }
      },
      shrujuPatches = {300, 600},
      runes = {
        maxLevel = 25
      },
      effects = {
        vignette = {
          blur = {.45, .45},
          radius = {.85, .65}
        },
        bloom = {
          alpha = {0, 255}
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
        eliteBuffCount = 2,
        types = {
          spuju = 0,
          vuju = 600
        }
      },
      shrujuPatches = {300, 600},
      runes = {
        maxLevel = 25
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
        eliteBuffCount = 3,
        types = {
          vuju = 0,
          spuju = 0,
          duju = 0
        }
      },
      shrujuPatches = {300, 600},
      runes = {
        maxLevel = 75
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
        eliteBuffCount = 4,
        types = {
          vuju = 0,
          spuju = 0,
          duju = 0
        }
      },
      shrujuPatches = {300, 600},
      runes = {
        maxLevel = 100
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
    stats = {'health', 'damage', 'speed', 'attackSpeed', 'spirit', 'haste'},
    statRanges = {
      health = {10, 250},
      damage = {3, 70},
      speed = {5, 80},
      attackSpeed = {.01, .15},
      spirit = {5, 200},
      haste = {.04, .2}
    },
    abilities = {
      bruju = {
        burst = {
          damage = {5, 50},
          range = {10, 50}
        }
      }
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
    suffixes = {
      attributes = {
        agility = {'the Wind'},
        agilityflow = {'Vigor'},
        agilitystrength = {'Skill'},
        agilityvitality = {'Energy'},
        flow = {'Spirit'},
        flowstrength = {'the Monk'},
        flowvitality = {'the Gods'},
        strength = {'Power'},
        strengthvitality = {'the Bear'},
        vitality = {'the Mountain'}
      },
      stats = {
        health = {'Fortitude'},
        damage = {'Might'},
        speed = {'Swiftness'},
        attackSpeed = {'Alacrity'},
        spirit = {'Essence'},
        haste = {'Refreshment'}
      },
      abilities = {
        burst = {'the Supernova'}
      }
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
    minions = {'thuju', 'bruju', 'buju', 'kuju'},
    runes = {},
    deck = {minions = {}, runes = {}},
    deckSlots = 1,
    biomes = {'forest'},
    highscores = {forest = 0, cavern = 0, tundra = 0, volcano = 0},
    name = 'Muju',
    color = 'purple'
  },

  defaultOptions = {
    resolution = nil,
    fullscreen = true,
    display = 1,
    vsync = false,
    msaa = 4,
    textureSmoothing = true,
    postprocessing = true,
    particles = true,
    mute = false,
    master = 1.0,
    music = 1.0,
    sound = .75,
    colorblind = false,
    powersave = true
  }
}
