local Thuju = {}
Thuju.name = 'Thuju'
Thuju.description = 'A bramble golem.  Exceptional at soaking up and reflecting damage as well as crowd control.'

----------------
-- Stats
----------------
Thuju.height = 64
Thuju.health = 150
Thuju.damage = 14
Thuju.range = 12
Thuju.attackSpeed = 1.15
Thuju.speed = 35
Thuju.spirit = 0
Thuju.haste = 1
Thuju.cost = 10
Thuju.attackParticleBone = 'region_lefthand'

----------------
-- Upgrades
----------------
Thuju.upgrades = {
  inspire = {
    level = 0,
    maxLevel = 3,
    costs = {200, 300, 400},
    levelRequirement = 1,
    name = 'Inspire',
    description = 'Thuju inspires allies when he spawns, buffing himself and nearby allies for 4 seconds.  Each level adds an additional effect.',
    x = -1,
    y = 0,
    values = {
      [1] = '+50% speed',
      [2] = '+50% speed, +50% armor',
      [3] = '+50% speed, +50% armor, +30% attack speed',
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
    levelRequirement = 1,
    name = 'Ward of Thorns',
    description = 'Thuju reflects a portion of melee damage dealt to him.',
    x = 0,
    y = 0,
    values = {
      [1] = '25% reflected',
      [2] = '45% reflected',
      [3] = '70% reflected',
      [4] = '100% reflected',
      [5] = '150% reflected'
    },
    bonuses = function()
      return data.ability.thuju.wardofthorns:bonuses()
    end,
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('wardofthorns')
      end
    end
  },

  tremor = {
    level = 0,
    maxLevel = 3,
    costs = {100, 200, 300},
    levelRequirement = 1,
    name = 'Tremor',
    description = 'Thuju slams the ground, damaging and stunning units in front of him.',
    x = 1,
    y = 0,
    values = {
      [1] = '30 damage, 1s stun',
      [2] = '60 damage, 2s stun',
      [3] = '90 damage, 3s stun',
    },
    bonuses = function()
      return data.ability.thuju.tremor:bonuses()
    end,
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('tremor')
      end
    end
  },

  briarlance = {
    level = 0,
    maxLevel = 1,
    costs = {300},
    prerequisites = {wardofthorns = 1},
    levelRequirement = 5,
    name = 'Briar Lance',
    description = 'Ward of Thorns also reflects a reduced amount for ranged attacks.',
    x = -1,
    y = 1,
    connectedTo = {'wardofthorns'},
    values = {
      [1] = 'Reflect ranged attacks (75% normal reflect)',
    }
  },

  vigor = {
    level = 0,
    maxLevel = 3,
    costs = {200, 300, 400},
    prerequisites = {wardofthorns = 1},
    levelRequirement = 3,
    name = 'Vigor',
    description = 'Each time Ward of Thorns is triggered, Thuju gains increased damage for 5 seconds.  This can stack multiple times.',
    x = 0,
    y = 1,
    connectedTo = {'wardofthorns'},
    values = {
      [1] = '+10 damage, up to 2 stacks.',
      [2] = '+15 damage, up to 3 stacks.',
      [3] = '+20 damage, up to 4 stacks.',
    },
    bonuses = function()
      local bonuses = {}
      local wardofthorns = data.ability.thuju.wardofthorns
      if wardofthorns.runePerStack > 0 then
        table.insert(bonuses, {'Runes', math.round(wardofthorns.runePerStack), 'damage per stack'})
      end
      return bonuses
    end
  },

  fissure = {
    level = 0,
    maxLevel = 3,
    costs = {100, 150, 200},
    prerequisites = {tremor = 1},
    levelRequirement = 3,
    name = 'Fissure',
    description = 'The range of Tremor is increased.',
    x = 1,
    y = 1,
    connectedTo = {'tremor'},
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
    levelRequirement = 15,
    name = 'Unbreakable',
    description = 'The defensive bonus from Impenetrable Hide is increased against ranged attacks.',
    x = -1,
    y = 2,
    connectedTo = {'impenetrablehide', 'briarlance'},
    values = {
      [1] = '1.50x armor against ranged attacks',
    }
  },

  impenetrablehide = {
    level = 0,
    maxLevel = 3,
    costs = {300, 400, 500},
    prerequisites = {vigor = 1},
    levelRequirement = 10,
    name = 'Impenetrable Hide',
    description = 'Each stack of vigor also reduces the damage Thuju takes from attacks.',
    x = 0,
    y = 2,
    connectedTo = {'vigor'},
    values = {
      [1] = '10% armor per stack',
      [2] = '15% armor per stack',
      [3] = '20% armor per stack',
    }
  },

  staggeringentry = {
    level = 0,
    maxLevel = 1,
    costs = {500},
    prerequisites = {fissure = 1},
    levelRequirement = 15,
    name = 'Staggering Entry',
    description = 'Thuju has a 50% chance to cast tremor when he spawns at no cooldown.',
    x = 1,
    y = 2,
    connectedTo = {'fissure'},
    values = {
      [1] = '100% awesomeness',
    }
  },

  infusedcarapace = {
    level = 0,
    maxLevel = 1,
    costs = {1000},
    levelRequirement = 20,
    name = 'Infused Carapace',
    description = 'Thuju takes 35% reduced damage from spells.',
    x = -1,
    y = 3,
    values = {
      [1] = '35% spell damage reduction',
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('infusedcarapace')
      end
    end
  },

  intimidate = {
    level = 0,
    maxLevel = 1,
    costs = {1500},
    levelRequirement = 20,
    name = 'Intimidate',
    description = 'When Thuju is brought into battle, he sharply lowers the attack of nearby enemies for 6 seconds.',
    x = 0,
    y = 3,
    values = {
      [1] = '50% less damage with attacks',
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('intimidate')
      end
    end
  }
}

Thuju.featured = {
  {'wardofthorns', 'Reflect damage.'},
  {'tremor', 'Damage and stun enemies in a line.'},
  {'inspire', 'Buff nearby allies when summoned.'},
  {'impenetrablehide', 'Gain armor whenever damage is taken.'}
}

return Thuju
