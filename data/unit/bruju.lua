local Bruju = {}
Bruju.name = 'Bruju'
Bruju.code = 'bruju'

----------------
-- Stats
----------------
Bruju.health = 80
Bruju.damage = 20
Bruju.range = 32
Bruju.attackSpeed = 1
Bruju.speed = 45


----------------
-- Upgrades
----------------
Bruju.upgrades = {
  empower = {
    level = 0,
    costs = {45, 65, 95, 135, 185},
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
      local damages = {[0] = 20, 26, 34, 44, 56, 70}
      unit.damage = damages[self.level]
    end
  },
  fortify = {
    level = 0,
    costs = {35, 60, 100, 150, 250},
    description = '',
    values = {
      [0] = '80 health',
      [1] = '125 health',
      [2] = '175 health',
      [3] = '235 health',
      [4] = '300 health',
      [5] = '400 health'
    },
    apply = function(self, unit)
      local healths = {[0] = 80, 125, 175, 235, 300, 400}
      local difference = healths[self.level] - unit.maxHealth
      unit.health = unit.health + difference
      unit.maxHealth = unit.maxHealth + difference
    end
  },
  burst = {
    level = 0,
    costs = {50, 75, 100, 125, 150},
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
