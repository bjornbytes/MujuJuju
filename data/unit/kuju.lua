local Kuju = {}
Kuju.name = 'Kuju'
Kuju.description = 'An ice witch who is great at stopping enemies in their tracks with powerful slows and cold magic.'

----------------
-- Stats
----------------
Kuju.health = 70
Kuju.damage = 14
Kuju.range = 150
Kuju.attackSpeed = 1.3
Kuju.speed = 35
Kuju.cost = 5

----------------
-- Upgrades
----------------
Kuju.upgrades = {
  frozenorb = {
    level = 0,
    maxLevel = 5,
    costs = {100, 150, 200, 250, 300},
    levelRequirement = 1,
    name = 'Frozen Orb',
    description = 'Kuju sends out a chilling orb that damages enemies it passes through.  It then returns to Kuju, damaging a second time.',
    x = -1,
    y = 0,
    connectedTo = {'windchill'},
    values = {
      [1] = '10 damage',
      [2] = '20 damage',
      [3] = '30 damage',
      [4] = '40 damage',
      [5] = '50 damage'
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('frozenorb')
      end
    end
  },
  frost = {
    level = 0,
    maxLevel = 5,
    costs = {100, 200, 300, 400, 500},
    levelRequirement = 1,
    name = 'Frost',
    description = 'Kuju\'s attacks slow their targets for 1 second.',
    x = 0,
    y = 0,
    connectedTo = {'shatter'},
    values = {
      [1] = '10% slow',
      [2] = '20% slow',
      [3] = '30% slow',
      [4] = '40% slow',
      [5] = '50% slow',
    }
  },
  frostbite = {
    level = 0,
    maxLevel = 5,
    costs = {100, 150, 200, 250, 300},
    levelRequirement = 1,
    name = 'Frostbite',
    description = 'Kuju creates a frozen zone lasting for 3 seconds that damages enemies.',
    x = 0,
    y = 0,
    connectedTo = {'coldfeet'},
    values = {
      [1] = '10 damage per second',
      [1] = '20 damage per second',
      [1] = '30 damage per second',
      [1] = '40 damage per second',
      [1] = '50 damage per second',
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('frostbite')
      end
    end
  },
  windchill = {
    level = 0,
    maxLevel = 3,
    costs = {150, 300, 450},
    prerequisites = {frozenorb = 3},
    levelRequirement = 3,
    name = 'Windchill',
    description = 'Frozen Orb slows enemies for 2 seconds.',
    x = -1,
    y = 1,
    connectedTo = {'frozenorb'},
    values = {
      [1] = '20% slow',
      [1] = '40% slow',
      [1] = '60% slow'
    }
  },
  shatter = {
    level = 0,
    maxLevel = 1,
    costs = {500},
    prerequisites = {frost = 1},
    levelRequirement = 5,
    name = 'Shatter',
    description = 'Kuju\'s attacks shatter into shards of ice which damage enemies behind her initial target.',
    x = 0,
    y = 1,
    connectedTo = {'frost', 'permafrost', 'brainfreeze', 'frigidsplinters'},
    values = {
      [1] = 'Attacks shatter'
    }
  },
  coldfeet = {
    level = 0,
    maxLevel = 1,
    costs = {500},
    prerequisites = {frostbite = 1},
    levelRequirement = 3,
    name = 'Cold Feet',
    description = 'Frostbite deals double damage if an enemy is slowed.',
    x = 1,
    y = 1,
    connectedTo = {'frostbite'},
    values = {
      [1] = '2.00x damage if target is slowed'
    }
  },
  permafrost = {
    level = 0,
    maxLevel = 1,
    costs = {1000},
    prerequisites = {shatter = 1},
    levelRequirement = 10,
    name = 'Permafrost',
    description = 'Kuju\'s attacks apply stacks of permafrost for 3 seconds.  At 3 stacks, the target is frozen in place, unable to move for 2 seconds.',
    x = -1,
    y = 2,
    connectedTo = {'shatter'},
    values = {
      [1] = '2s root'
    }
  },
  brainfreeze = {
    level = 0,
    maxLevel = 3,
    costs = {500, 500, 500},
    prerequisites = {shatter = 1},
    levelRequirement = 10,
    name = 'Brainfreeze',
    description = 'Kuju\'s attacks lower the attack speed of enemies for 3 seconds.',
    x = 0,
    y = 2,
    connectedTo = {'shatter'},
    values = {
      [1] = '15% attack speed reduction',
      [2] = '30% attack speed reduction',
      [3] = '45% attack speed reduction',
    }
  },
  frigidsplinters = {
    level = 0,
    maxLevel = 1,
    costs = {1000},
    prerequisites = {shatter = 1},
    levelRequirement = 10,
    name = 'Frigid Splinters',
    description = 'Ice shards from Shatter also apply on-hit effects.',
    x = 1,
    y = 2,
    connectedTo = {'shatter'},
    values = {
      [1] = 'Shards apply on-hit effects',
    }
  },
  veinsofice = {
    level = 0,
    maxLevel = 1,
    costs = {1500},
    prerequisites = {},
    levelRequirement = 15,
    name = 'Veins of Ice',
    description = 'Kuju deals more damage based on how slow her targets are.',
    x = 0,
    y = 3,
    connectedTo = {},
    values = {
      [1] = '1% extra damage per 1% slow',
    }
  }
}

Kuju.attackSpell = 'kujuattack'

return Kuju
