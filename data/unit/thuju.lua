local Thuju = {}
Thuju.name = 'Thuju'
Thuju.description = 'A bramble golem.  Exceptional at soaking up and reflecting damage as well as crowd control.'

----------------
-- Stats
----------------
Thuju.health = 150
Thuju.damage = 14
Thuju.range = 16
Thuju.attackSpeed = 1.15
Thuju.speed = 35
Thuju.flow = 1

Thuju.cost = 5


----------------
-- Upgrades
----------------
Thuju.upgrades = {
  inspire = {
    level = 0,
    maxLevel = 3,
    costs = {100, 200, 300},
    name = 'Inspire',
    description = 'Thuju beats his chest, buffing himself and nearby allies for 4 seconds.  Each level adds an additional effect.',
    values = {
      [1] = '+50 speed',
      [2] = '+50 speed, +50% armor',
      [3] = '+50 speed, +50% armor, +50% attack speed',
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('inspire')
      end
    end
  },
  wardofthorns = {
    level = 0,
    maxLevel = 5,
    costs = {100, 150, 200, 250, 300},
    name = 'Ward of Thorns',
    description = 'Thuju reflects a portion of melee damage dealt to him.',
    values = {
      [1] = '10% reflected',
      [2] = '25% reflected',
      [3] = '45% reflected',
      [4] = '70% reflected',
      [5] = '100% reflected'
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('wardofthorns')
      end
    end
  },
  tremor = {
    level = 0,
    maxLevel = 3,
    costs = {200, 300, 400},
    name = 'Tremor',
    description = 'Thuju slams the ground, damaging and stunning units in front of him.',
    values = {
      [1] = '30 damage, 1s stun',
      [2] = '60 damage, 2s stun',
      [3] = '90 damage, 3s stun'
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('tremor')
      end
    end
  },
  briarlance = {
    level = 0,
    maxLevel = 1,
    costs = {500},
    prerequisites = {wardofthorns = 1},
    name = 'Briar Lance',
    description = 'Ward of Thorns also reflects half the amount for ranged attacks.',
    values = {
      [1] = 'Reflect ranged attacks',
    }
  },
  vigor = {
    level = 0,
    maxLevel = 3,
    costs = {300, 300, 300},
    prerequisites = {wardofthorns = 1},
    name = 'Vigor',
    description = 'Each time Ward of Thorns is triggered, Thuju gains increased damage for 5 seconds.  This can stack multiple times.',
    values = {
      [1] = '+10 damage, up to 2 stacks.',
      [2] = '+15 damage, up to 3 stacks.',
      [3] = '+20 damage, up to 4 stacks.',
    }
  },
  fissure = {
    level = 0,
    maxLevel = 3,
    costs = {100, 200, 300},
    prerequisites = {tremor = 1},
    name = 'Fissure',
    description = 'The range of Tremor is increased.',
    values = {
      [0] = '180 range',
      [1] = '240 range',
      [2] = '300 range',
      [3] = '360 range',
    }
  },
  unbreakable = {
    level = 0,
    maxLevel = 1,
    costs = {500},
    prerequisites = {impenetrablehide = 1, briarlance = 1},
    name = 'Unbreakable',
    description = 'The defensive bonus from Impenetrable Hide is doubled against ranged attacks.',
    values = {
      [1] = '1.50x armor against ranged attacks',
    }
  },
  impenetrablehide = {
    level = 0,
    maxLevel = 3,
    costs = {500, 500, 500},
    prerequisites = {vigor = 1},
    name = 'Impenetrable Hide',
    description = 'Each stack of vigor also reduces the damage Thuju takes from attacks.',
    values = {
      [1] = '10% armor per stack',
      [2] = '15% armor per stack',
      [3] = '20% armor per stack',
    }
  },
  alacrity = {
    level = 0,
    maxLevel = 1,
    costs = {1000},
    name = 'Alacrity',
    description = 'Each time Thuju is damaged by a spell or attack, the cooldown of Tremor and Inspire is reduced by 1 second.',
    values = {
      [1] = '1s per attack',
    }
  },
  infusedcarapace = {
    level = 0,
    maxLevel = 1,
    costs = {1500},
    name = 'Infused Carapace',
    description = 'Thuju takes 35% reduced damage from spells.',
    values = {
      [1] = '35% spell damage reduction',
    }
  },
  taunt = {
    level = 0,
    maxLevel = 1,
    costs = {1500},
    name = 'Taunt',
    description = 'Any enemies Thuju damage will immediately attack Thuju.',
    values = {
      [1] = 'Taunt enemies',
    }
  },
  staggeringentry = {
    level = 0,
    maxLevel = 1,
    costs = {1000},
    prerequisites = {alacrity = 1},
    name = 'Staggering Entry',
    description = 'When Thuju is summoned, he casts all of his abilities (cooldowns are not triggered).',
    values = {
      [1] = '100% awesomeness',
    }
  },
}

Thuju.upgradeOrder = {'wardofthorns', 'tenacity', 'impenetrablehide', 'taunt', 'tremor'}

return Thuju
