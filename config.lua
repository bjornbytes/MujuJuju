return {

  starters = {
    'bruju',
    'thuju',
    'xuju',
    'kuju'
  },

  biomeOrder = {
    'forest',
    'cavern',
    'tundra',
    'volcano'
  },

  hats = {'beret', 'crown', 'eyepatch', 'horns', 'party', 'santa', 'wizard'},

  attributes = {
    list = {'vitality', 'strength', 'agility', 'flow'},
    baseCost = 30,
    costIncrease = 20,
    descriptions = {
      vitality = 'Increases the health of your minion.',
      strength = 'Increases the damage that minions deal with attacks.',
      agility = 'Makes your minions move faster and attack faster.',
      flow = 'Makes your minions deal more damage with special abilities and reduces their cooldowns.'
    },
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
      haste = .2,
      spirit = 12
    }
  },

  elites = {
    baseModifier = .005,
    levelModifier = .0015,
    jujuModifier = 3,
    scale = 1.25,
    healthModifier = 3,
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
        lifesteal = .3
      },
      spined = {
        reflect = 1
      },
      venomous = {
        dotModifier = .35,
        dotTimer = 3
      },
      hulking = {
        healthModifier = 2,
        slow = .5
      },
      demolisher = {
        damageModifier = 5
      },
      rallying = {
        range = 200,
        speedModifier = 2
      },
      frenzied = {
        frenzy = .3,
        haste = 1,
        healthModifier = .5
      },
      pummeling = {
        offset = 75
      },
      cursed = {
        range = 100,
        weakenModifier = .6
      }
    }
  },

  player = {
    baseCooldown = 3,
    minCooldown = .75,
    baseJuju = 50,
    jujuRate = 1,
    maxHealthPerMinute = 15,
    colors = {
      purple = {.6, .2, .9},
      red = {.9, .2, .2},
      blue = {.2, .2, .9},
      green = {.2, .9, .2},
      black = {.3, .3, .3},
      white = {1, 1, 1}
    },
    colorOrder = {'purple', 'red', 'blue', 'green', 'black', 'white'}
  },

  shruju = {
    lifetime = 60
  },

  biomes = {
    forest = {
      name = 'The Overgrowth',
      description = 'A forest',
      minion = 'bruju'
    },

    cavern = {
      name = 'The Hollow',
      description = 'A cave',
      minion = 'xuju'
    },

    tundra = {
      name = 'The Wild North',
      description = 'A mountain',
      minion = 'kuju'
    },

    volcano = {
      name = 'The Cinders',
      description = 'A volcano',
      minion = 'thuju'
    }
  },

  juju = {
    minimum = {
      base = 20,
      exponent = .7,
      coefficient = 1
    },
    maximum = {
      base = 30,
      exponent = .7,
      coefficient = 1.2
    }
  },

  medals = {
    bronze = 300,
    silver = 600,
    gold = 1200
  },

  runes = {
    maxLevels = {
      forest = 35,
      cavern = 50,
      tundra = 70,
      volcano = 100
    },
    stats = {'health', 'damage', 'speed', 'attackSpeed', 'spirit', 'haste'},
    statRanges = {
      health = {10, 100},
      damage = {3, 30},
      speed = {3, 30},
      attackSpeed = {.03, .3},
      spirit = {10, 100},
      haste = {.2, 1}
    },
    abilities = {
      bruju = {
        burst = {
          damage = {5, 50},
          range = {10, 50}
        },
        siphon = {
          lifesteal = {.01, .1}
        },
        retaliation = {
          frenzy = {.03, .15}
        },
        rewind = {
          chance = {.01, .15}
        }
      },
      xuju = {
        rend = {
          chance = {.01, .05}
        },
        ghostarmor = {
          chance = {.01, .05}
        },
        voidmetal = {
          chance = {.01, .05}
        },
        fury = {
          perStack = {.01, .08}
        }
      },
      kuju = {
        frozenorb = {
          damage = {5, 20},
          slow = {.02, .15}
        },
        avalanche = {
          knockback = {10, 30}
        },
        frostbite = {
          damage = {1, 2},
          size = {.1, .4}
        },
        shiverarmor = {
          damage = {5, 20}
        },
        crystallize = {
          stunChance = {.03, .15}
        }
      },
      thuju = {
        wardofthorns = {
          reflect = {.05, .3}
        },
        tremor = {
          damage = {5, 50},
          stun = {.1, .75}
        },
        vigor = {
          perStack = {2, 10}
        }
      }
    },
    abilityFormatters = {
      bruju = {
        siphon = {
          lifesteal = {'percent', 'lifesteal'}
        },
        retaliation = {
          frenzy = {'percent', 'attack speed'}
        },
        rewind = {
          chance = {'percent', 'chance'}
        }
      },
      xuju = {
        rend = {
          chance = {'percent', 'crit chance'}
        },
        ghostarmor = {
          chance = {'percent', 'chance'}
        },
        voidmetal = {
          chance = {'percent', 'chance'}
        },
        fury = {
          perStack = {'percent', 'attack speed per stack'}
        }
      },
      kuju = {
        frozenorb = {
          slow = {'percent', 'slow'}
        },
        avalanche = {
          knockback = {'flat', 'knockback distance'}
        },
        frostbite = {
          size = {'percent', 'size'}
        },
        crystallize = {
          stunChance = {'percent', 'chance'}
        }
      },
      thuju = {
        wardofthorns = {
          reflect = {'percent', 'damage reflected'}
        },
        tremor = {
          stun = {'time', 'stun duration'}
        },
        vigor = {
          perStack = {'flat', 'damage per stack'}
        }
      }
    },
    abilityProxies = {
      xuju = {
        rend = 'buff',
        ghostarmor = 'buff',
        voidmetal = 'buff',
        fury = {'buff', 'rend'}
      },
      kuju = {
        avalanche = {'ability', 'frozenorb'},
        crystallize = {'ability', 'shiverarmor'}
      },
      thuju = {
        vigor = {'ability', 'wardofthorns'}
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
        burst = {'the Supernova', 'Decimation', 'Eruption', 'the Explosion'},
        siphon = {'the Leech', 'the Lamprey', 'Vampirism'},
        retaliation = {'Vengeance', 'Revenge', 'Retribution'},
        rewind = {'the Ages', 'Foresight'},
        rend = {'Laceration', 'the Predator', 'Talons', 'Claws'},
        ghostarmor = {'the Shade', 'the Wraith', 'Fog'},
        voidmetal = {'Feint', 'Plasma'},
        fury = {'Ire', 'Furor'},
        frozenorb = {'the Snowflake', 'Ice'},
        avalanche = {'the Glacier', 'Pummeling'},
        frostbite = {'the Arctic', 'the Tundra', 'the Poles'},
        shiverarmor = {'Shudders', 'Hypothermia', 'Chills', 'Shivers'},
        crystallize = {'the Ice Age', 'Stasis', 'Crystals'},
        wardofthorns = {'Spines', 'the Porcupine', 'Quills', 'the Thicket'},
        tremor = {'the Earthquake', 'Disaster', 'the Fissure'},
        vigor = {'Vim', 'the Brute', 'Brawn'}
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
    baseDamageScaling = 3,
    upgradeCostIncrease = 1,
    attributeCostIncrease = 1
  },

  enemies = {
    forest = {
      minEnemyRate = 9,
      maxEnemyRate = 11,
      minEnemyRateDecay = .025,
      maxEnemyRateDecay = .025,
      maxEnemiesCoefficient = .08,
      levelScale = .75,
      maxElites = 1,
      maxEliteBuffCount = 1,
      eliteLevelThreshold = 50,
      types = {
        duju = 0,
        spuju = 360
      }
    },
    cavern = {
      minEnemyRate = 9,
      maxEnemyRate = 11,
      minEnemyRateDecay = .025,
      maxEnemyRateDecay = .025,
      maxEnemiesCoefficient = .08,
      levelScale = .85,
      maxElites = 1,
      maxEliteBuffCount = 1,
      eliteLevelThreshold = 50,
      types = {
        spuju = 0,
        vuju = 600
      }
    },
    tundra = {
      level = 5,
      minEnemyRate = 9,
      maxEnemyRate = 11,
      minEnemyRateDecay = .025,
      maxEnemyRateDecay = .025,
      maxEnemiesCoefficient = .08,
      levelScale = .95,
      maxElites = 2,
      maxEliteBuffCount = 2,
      eliteLevelThreshold = 60,
      types = {
        vuju = 300,
        spuju = 0,
        duju = 0
      }
    },
    volcano = {
      level = 10,
      minEnemyRate = 9,
      maxEnemyRate = 11,
      minEnemyRateDecay = .025,
      maxEnemyRateDecay = .025,
      maxEnemiesCoefficient = .08,
      levelScale = 1.5,
      maxElites = 3,
      maxEliteBuffCount = 3,
      eliteLevelThreshold = 100,
      types = {
        vuju = 240,
        spuju = 120,
        duju = 0
      }
    },
    survival = {
      minEnemyRate = 9,
      maxEnemyRate = 11,
      minEnemyRateDecay = .025,
      maxEnemyRateDecay = .025,
      maxEnemiesCoefficient = .08,
      levelScale = 1,
      maxElites = 3,
      maxEliteBuffCount = 3,
      eliteLevelThreshold = 50,
      types = {
        duju = 0,
        spuju = 0,
        vuju = 0
      }
    }
  },

  defaultUser = {
    name = 'Muju',
    color = 'purple',
    hats = {},
    hat = nil,
    runes = {
      stash = {},
      bruju = {},
      xuju = {},
      kuju = {},
      thuju = {}
    },
    campaign = {
      medals = {
        forest = {},
        cavern = {},
        tundra = {},
        volcano = {}
      },
      hatHistory = {
        forest = nil,
        cavern = nil,
        tundra = nil,
        volcano = nil
      }
    },
    survival = {
      bestTime = 0,
      minions = {}
    }
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
    powersave = true,
    offline = false
  },

  effects = {
    forest = {
      vignette = {
        blur = {.45, .45},
        radius = {.85, .65}
      },
      bloom = {
        alpha = {0, 20}
      }
    },
    cavern = {
      vignette = {
        blur = {.6, 1.15},
        radius = {.75, .75}
      },
      bloom = {
        alpha = {5, 20}
      }
    },
    tundra = {
      vignette = {
        blur = {.45, 1.15},
        radius = {.85, .85}
      },
      bloom = {
        alpha = {10, 20}
      }
    },
    volcano = {
      vignette = {
        blur = {.45, 1.15},
        radius = {.85, .85}
      },
      bloom = {
        alpha = {10, 70}
      }
    }
  }
}
