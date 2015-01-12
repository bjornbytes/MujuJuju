local Bruju = {}
Bruju.code = 'bruju'
Bruju.name = 'Bruju'
Bruju.description = 'A treant with spiritual powers.  Specializes in dealing high damage and regenerating health.'

----------------
-- Stats
----------------
Bruju.width = 48
Bruju.health = 85
Bruju.damage = 20
Bruju.range = 12
Bruju.attackSpeed = 1
Bruju.speed = 45

Bruju.cost = 12


----------------
-- Upgrades
----------------
Bruju.upgrades = {
  empower = {
    level = 0,
    reqLevel = 2,
    name = 'Empower',
    description = '+10 damage',
    values = {
      [0] = '20 damage',
      [1] = '26 damage',
      [2] = '34 damage',
      [3] = '44 damage',
      [4] = '56 damage',
      [5] = '70 damage'
    },
    apply = function(self, unit)
      unit.damage = unit.damage + 10
    end
  },
  fortify = {
    level = 0,
    reqLevel = 2,
    name = 'Fortify',
    description = '+40 health',
    values = {
      [0] = '85 health',
      [1] = '130 health',
      [2] = '180 health',
      [3] = '240 health',
      [4] = '300 health',
      [5] = '400 health'
    },
    apply = function(self, unit)
      unit.health = unit.health + 40
      unit.maxHealth = unit.maxHealth + 40
    end
  },
  sanctuary = {
    level = 0,
    reqLevel = 3,
    name = 'Sanctuary',
    description = 'Heal nearby allies for 30 health on death.',
    values = {
      [1] = '20 + 30% damage',
      [2] = '30 + 50% damage',
      [3] = '40 + 70% damage'
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('burst')
      end
    end
  },
  siphon = {
    level = 0,
    reqLevel = 3,
    name = 'Siphon',
    description = 'Gain 20% lifesteal.',
    values = {
      [1] = '20% lifesteal',
      [2] = '35% lifesteal',
      [3] = '50% lifesteal'
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('siphon')
      end
    end
  },
  burst = {
    level = 0,
    reqLevel = 4,
    name = 'Burst',
    description = 'Deal 40 damage to nearby enemies on death.',
    values = {
      [1] = '20 + 30% damage',
      [2] = '30 + 50% damage',
      [3] = '40 + 70% damage'
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('burst')
      end
    end
  },
  rewind = {
    level = 0,
    reqLevel = 4,
    name = 'Rewind',
    description = 'Grants a 30% chance to quickly heal any damage taken.',
    values = {
      [1] = '20% lifesteal',
      [2] = '35% lifesteal',
      [3] = '50% lifesteal'
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('rewind')
      end
    end
  }
}

Bruju.upgradeOrder = {'empower', 'fortify', 'sanctuary', 'siphon', 'burst', 'rewind'}

return Bruju
