local Thuju = {}
Thuju.code = 'thuju'
Thuju.name = 'Thuju'
Thuju.description = 'Yay Thuju.'

----------------
-- Stats
----------------
Thuju.health = 160
Thuju.damage = 15
Thuju.range = 16
Thuju.attackSpeed = 1.15
Thuju.speed = 35

Thuju.cost = 12


----------------
-- Upgrades
----------------
Thuju.upgrades = {
  wardofthorns = {
    level = 0,
    costs = {30, 50, 80, 120, 170},
    name = 'Ward of Thorns',
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
  tenacity = {
    level = 0,
    costs = {30, 65, 105, 145, 185},
    name = 'Tenacity',
    description = 'Thuju strengthens his resolve, increasing his maximum health.',
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
    description = 'Thuju hardens his body when he is struck.  He takes reduced damage from all sources for 3 seconds, stacking multiple times.  The bonus is 150% effective against ranged attacks.',
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
    description = 'Thuju beats his chest, forcing nearby enemies to attack him for 3 seconds.  Thuju gains damage during the taunt based on how many enemies are taunted.',
    values = {
      [1] = '100 range, 12 second cooldown, 10 damage per enemy',
      [2] = '150 range, 10 second cooldown, 20 damage per enemy',
      [3] = '200 range, 8 second cooldown, 30 damage per enemy'
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
    description = 'Thuju slams the ground in the direction he is facing, causing the tectonic plates of the Earth to erupt in front of him.  Any units unfortunate enough to be caught in the area of impact take damage and are stunned.',
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
