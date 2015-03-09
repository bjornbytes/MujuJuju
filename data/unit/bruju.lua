local Bruju = {}
Bruju.name = 'Bruju'
Bruju.description = 'A treant with spiritual powers.  Specializes in dealing high damage and regenerating health.'

----------------
-- Stats
----------------
Bruju.width = 48
Bruju.health = 85
Bruju.damage = 18
Bruju.range = 12
Bruju.attackSpeed = 1.1
Bruju.speed = 45
Bruju.haste = 1
Bruju.spirit = 0
Bruju.cost = 10
Bruju.attackParticleBone = 'region_righthand'

----------------
-- Upgrades
----------------
Bruju.upgrades = {
  siphon = {
    level = 0,
    maxLevel = 5,
    costs = {100, 150, 200, 250, 300},
    levelRequirement = 1,
    name = 'Siphon',
    description = 'Bruju siphon life from their enemies with every strike, granting lifesteal.',
    x = -1,
    y = 0,
    values = {
      [1] = '8% lifesteal',
      [2] = '12% lifesteal',
      [3] = '16% lifesteal',
      [4] = '20% lifesteal',
      [5] = '24% lifesteal',
    },
    bonuses = function()
      return data.ability.bruju.siphon:bonuses()
    end,
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('siphon')
      end
    end
  },

  burst = {
    level = 0,
    maxLevel = 5,
    costs = {100, 150, 200, 250, 300},
    levelRequirement = 1,
    name = 'Burst',
    description = 'Bruju burst into a spirit flame on death, damaging nearby enemies.',
    x = 0,
    y = 0,
    values = {
      [1] = '20 damage',
      [2] = '40 damage',
      [3] = '70 damage',
      [4] = '110 damage',
      [5] = '160 damage',
    },
    bonuses = function(self)
      return data.ability.bruju.burst:bonuses()
    end,
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('burst')
      end
    end
  },

  retaliation = {
    level = 0,
    maxLevel = 1,
    costs = {250},
    levelRequirement = 1,
    name = 'Retaliation',
    description = 'Bruju gains attack speed while Muju is in the juju realm.',
    x = 1,
    y = 0,
    values = {
      [1] = '30% attack speed'
    },
    bonuses = function()
      return data.ability.bruju.retaliation:bonuses()
    end,
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('retaliation')
      end
    end
  },

  equilibrium = {
    level = 0,
    maxLevel = 1,
    costs = {500},
    prerequisites = {siphon = 3},
    levelRequirement = 5,
    name = 'Equilibrium',
    description = 'Bruju gains double lifesteal from Siphon when below 40% health.',
    x = -1,
    y = 1,
    connectedTo = {'siphon'},
    values = {
      [1] = '2.00x lifesteal'
    }
  },

  eruption = {
    level = 0,
    maxLevel = 3,
    costs = {100, 200, 300},
    prerequisites = {burst = 1},
    levelRequirement = 3,
    name = 'Eruption',
    description = 'The range of burst is increased',
    x = 0,
    y = 1,
    connectedTo = {'burst'},
    values = {
      [0] = '60 range',
      [1] = '80 range',
      [2] = '110 range',
      [3] = '150 range'
    }
  },

  rewind = {
    level = 0,
    maxLevel = 3,
    costs = {300, 300, 300},
    levelRequirement = 5,
    name = 'Rewind',
    description = 'Bruju has a chance to quickly heal any damage taken.',
    x = 1,
    y = 1,
    values = {
      [1] = '5% chance',
      [2] = '10% chance',
      [3] = '15% chance'
    },
    bonuses = function()
      return data.ability.bruju.rewind:bonuses()
    end,
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('rewind')
      end
    end
  },

  fortify = {
    level = 0,
    maxLevel = 3,
    costs = {300, 300, 300},
    levelRequirement = 10,
    name = 'Fortify',
    description = 'Bruju\'s maximum health is increased.',
    x = -1,
    y = 2,
    values = {
      [1] = '30% increase',
      [2] = '50% increase',
      [3] = '70% increase'
    },
    apply = function(self, unit)
      if self.level > 0 then
        local modifiers = {1.3, 1.5, 1.7}
        unit.health = unit.health * modifiers[self.level]
      end
    end
  },

  impulse = {
    level = 0,
    maxLevel = 1,
    costs = {1000},
    prerequisites = {burst = 1, rewind = 1},
    levelRequirement = 10,
    name = 'Impulse',
    description = 'Every time rewind is triggered, Bruju ruptures the fabric of time, casting Burst.',
    x = 1,
    y = 2,
    connectedTo = {'rewind'},
    values = {
      [1] = 'So much burst.',
    }
  },

  clarity = {
    level = 0,
    maxLevel = 1,
    costs = {500},
    prerequisites = {fortify = 1},
    levelRequirement = 15,
    name = 'Clarity',
    description = 'Reduces the duration of crowd control effects.',
    x = -1,
    y = 3,
    connectedTo = {'fortify'},
    values = {
      [1] = '50% reduction.',
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit.buffs:add('clarity')
      end
    end
  },

  sanctuary = {
    level = 0,
    maxLevel = 1,
    costs = {1000},
    prerequisites = {burst = 1, eruption = 1},
    levelRequirement = 15,
    name = 'Sanctuary',
    description = 'Burst also heals allies for a portion of the damage dealt.',
    x = 0,
    y = 3,
    connectedTo = {'eruption'},
    values = {
      [1] = '50% of the damage heals.',
    }
  },

  moxie = {
    level = 0,
    maxLevel = 1,
    costs = {1500},
    levelRequirement = 20,
    name = 'Moxie',
    description = 'Bruju gains damage proportional to his maximum health.',
    x = -1,
    y = 4,
    values = {
      [1] = '10% maximum health converted to damage',
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit.damage = unit.damage + (unit.health * .1)
      end
    end
  },

  conduction = {
    level = 0,
    maxLevel = 1,
    costs = {1500},
    levelRequirement = 20,
    name = 'Conduction',
    description = 'All healing is increased.',
    x = 0,
    y = 4,
    values = {
      [1] = '10% increased healing from all sources.',
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit.buffs:add('conduction')
      end
    end
  }
}

Bruju.featured = {
  {'siphon', 'Steal health from enemies with every attack.'},
  {'burst', 'Explode on death to damage enemies.'},
  {'rewind', 'Move backwards in time to avoid taking damage.'},
  {'moxie', 'Convert health into damage.'}
}

return Bruju
