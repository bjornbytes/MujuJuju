local Thuju = {}
Thuju.code = 'thuju'
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

Thuju.cost = 12


----------------
-- Upgrades
----------------
Thuju.upgrades = {
  wardofthorns = {
    level = 0,
    costs = {30, 50, 80, 120, 170},
    name = 'Ward of Thorns',
    description = 'Thuju reflects a portion of melee damage dealt to him.',
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
  tenacity = {
    level = 0,
    costs = {30, 65, 105, 145, 185},
    name = 'Tenacity',
    description = 'Thuju\'s strengthens his carapace, increasing his maximum health.',
    values = {
      [0] = '150 health',
      [1] = '200 health',
      [2] = '250 health',
      [3] = '300 health',
      [4] = '400 health',
      [5] = '500 health'
    },
    apply = function(self, unit)
      local healthIncreases = {[0] = 0, 50, 100, 150, 250, 350}
      local increase = healthIncreases[self.level]
      unit.health = unit.health + increase
      unit.maxHealth = unit.maxHealth + increase
    end
  },
  impenetrablehide = {
    level = 0,
    costs = {25, 75, 125, 175, 225},
    name = 'Impenetrable Hide',
    description = 'Thuju gains armor for 3 seconds when struck, stacking multiple times.  The effect is increased by 200% against ranged attacks.',
    values = {
      [1] = '5% damage reduction, stacking up to 3 times',
      [2] = '8% damage reduction, stacking up to 4 times',
      [3] = '11% damage reduction, stacking up to 5 times',
      [4] = '14% damage reduction, stacking up to 5 times',
      [5] = '17% damage reduction, stacking up to 5 times'
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('impenetrablehide')
      end
    end
  },
  taunt = {
    level = 0,
    costs = {100, 200, 300},
    prerequisites = {wardofthorns = 1, tenacity = 1},
    name = 'Taunt',
    description = 'Thuju forces nearby enemies to attack him for 3 seconds, and gains damage for 5 seconds based on how many enemies are taunted.',
    values = {
      [1] = '100 range, 10 second cooldown, 15 damage per enemy',
      [2] = '150 range, 8 second cooldown, 30 damage per enemy',
      [3] = '200 range, 6 second cooldown, 45 damage per enemy'
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('taunt')
      end
    end
  },
  tremor = {
    level = 0,
    costs = {100, 200, 300},
    prerequisites = {tenacity = 1, impenetrablehide = 1},
    name = 'Tremor',
    description = 'Thuju slams the ground, damaging and stunning units in front of him.',
    values = {
      [1] = '30 damage, 1s stun',
      [2] = '60 damage, 1.5s stun',
      [3] = '90 damage, 2s stun'
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('tremor')
      end
    end
  }
}

Thuju.upgradeOrder = {'wardofthorns', 'tenacity', 'impenetrablehide', 'taunt', 'tremor'}

return Thuju
