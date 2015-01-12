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
    costs = {45, 65, 95, 135, 185},
    name = 'Empower',
    description = 'Bruju strike with increased force.',
    values = {
      [0] = '20 damage',
      [1] = '26 damage',
      [2] = '34 damage',
      [3] = '44 damage',
      [4] = '56 damage',
      [5] = '70 damage'
    },
    apply = function(self, unit)
      local damageIncreases = {[0] = 0, 6, 14, 24, 36, 50}
      unit.damage = unit.damage + damageIncreases[self.level]
    end
  },
  fortify = {
    level = 0,
    costs = {35, 60, 100, 150, 250},
    name = 'Fortify',
    description = 'Bruju is empowered with spiritual energy, increasing his maximum health.',
    values = {
      [0] = '85 health',
      [1] = '130 health',
      [2] = '180 health',
      [3] = '240 health',
      [4] = '300 health',
      [5] = '400 health'
    },
    apply = function(self, unit)
      local healthIncreases = {[0] = 0, 45, 95, 145, 215, 315}
      local increase = healthIncreases[self.level]
      unit.health = unit.health + increase
      unit.maxHealth = unit.maxHealth + increase
    end
  },
  burst = {
    level = 0,
    costs = {30, 60, 90, 120, 150},
    name = 'Burst',
    description = 'Bruju burst into a spirit flame on death, damaging nearby enemies.',
    values = {
      [1] = '20 damage + 20% attack damage',
      [2] = '35 damage + 30% attack damage',
      [3] = '50 damage + 40% attack damage',
      [4] = '65 damage + 50% attack damage',
      [5] = '80 damage + 60% attack damage'
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('burst')
      end
    end
  },
  siphon = {
    level = 0,
    costs = {100, 200, 300},
    prerequisites = {empower = 1, fortify = 1},
    name = 'Siphon',
    description = 'Bruju siphon life from their enemies with every strike, granting them lifesteal.',
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
  sanctuary = {
    level = 0,
    costs = {100, 200, 300},
    prerequisites = {fortify = 1, burst = 1},
    name = 'Sanctuary',
    description = 'Burst also heals allies based on its damage.',
    values = {
      [1] = '20 + 30% damage',
      [2] = '30 + 50% damage',
      [3] = '40 + 70% damage'
    }
  }
}

Bruju.upgradeOrder = {'empower', 'fortify', 'burst', 'siphon', 'sanctuary'}

return Bruju
