local Thuju = {}
Thuju.name = 'Thuju'
Thuju.code = 'thuju'

----------------
-- Stats
----------------
Thuju.health = 150
Thuju.damage = 16
Thuju.range = 32
Thuju.attackSpeed = 1.5
Thuju.speed = 35


----------------
-- Upgrades
----------------
Thuju.upgrades = {
  tenacity = {
    level = 0,
    costs = {45, 75, 115, 165, 225},
    description = 'Thuju strengthens his resolve, allowing him to withstand more damage.',
    values = {
      [0] = '150 health',
      [1] = '200 health',
      [2] = '250 health',
      [3] = '300 health',
      [4] = '400 health',
      [5] = '500 health'
    },
    apply = function(self, unit)
      local healths = {[0] = 150, 200, 250, 300, 400, 500}
      local difference = healths[self.level] - unit.maxHealth
      unit.health = unit.health + difference
      unit.maxHealth = unit.maxHealth + difference
    end
  },
  wardofthorns = {
    level = 0,
    costs = {35, 60, 100, 150, 250},
    description = 'Thuju protrudes splintering thorns from his hide, causing him to reflect a portion of melee damage dealt to him.',
    values = {
      [0] = '10% reflected',
      [1] = '25% reflected',
      [2] = '45% reflected',
      [3] = '70% reflected',
      [4] = '100% reflected',
      [5] = '150% reflected'
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('wardofthorns')
      end
    end
  },
  impenetrablehide = {
    level = 0,
    costs = {50, 75, 110, 155, 210},
    description = 'Thuju burst into a spirit flame on death, damaging nearby enemies.',
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
    description = 'Thuju siphon life from their enemies with every strike, granting them lifesteal.',
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

Thuju.upgradeOrder = {'empower', 'fortify', 'burst', 'siphon', 'sanctuary'}


----------------
-- Abilities
----------------
Thuju.abilities = {'taunt', 'tremor'}

return Thuju
