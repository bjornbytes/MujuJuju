local Bruju = {}
Bruju.name = 'Bruju'
Bruju.code = 'bruju'

----------------
-- Stats
----------------
Bruju.health = 80
Bruju.damage = 20
Bruju.range = 32
Bruju.attackSpeed = 1.3
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
      [0] = '80 health',
      [1] = '125 health',
      [2] = '175 health',
      [3] = '235 health',
      [4] = '300 health',
      [5] = '400 health'
    },
    apply = function(self, unit)
      local healthIncreases = {[0] = 0, 45, 95, 155, 280, 380}
      local increase = healthIncreases[self.level]
      unit.health = unit.health + increase
      unit.maxHealth = unit.maxHealth + increase
    end
  },
  burst = {
    level = 0,
    costs = {50, 75, 100, 125, 150},
    name = 'Burst',
    description = 'Bruju burst into a spirit flame on death, damaging nearby enemies.',
    values = {
      [1] = '20 damage',
      [2] = '40 damage',
      [3] = '60 damage',
      [4] = '80 damage',
      [5] = '100 damage'
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('burst')
      end
    end
  },
  siphon = {
    level = 0,
    costs = {80, 160, 240},
    prerequisites = {empower = 3, fortify = 3},
    name = 'Siphon',
    description = 'Bruju siphon life from their enemies with every strike, granting them lifesteal.',
    values = {
      [1] = '10% lifesteal',
      [2] = '20% lifesteal',
      [3] = '30% lifesteal'
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('siphon')
      end
    end
  },
  sanctuary = {
    level = 0,
    costs = {80, 160, 240},
    prerequisites = {fortify = 3, burst = 3},
    name = 'Sanctuary',
    description = 'The spirit flame leaves behind an aura that slowly heals allies.',
    values = {
      [1] = '10 hp/s for 3 seconds.',
      [2] = '20 hp/s for 4 seconds.',
      [3] = '30 hp/s for 5 seconds.'
    }
  }
}

Bruju.upgradeOrder = {'empower', 'fortify', 'burst', 'siphon', 'sanctuary'}

return Bruju
