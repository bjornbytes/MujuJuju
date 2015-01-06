local Thuju = {}
Thuju.name = 'Thuju'
Thuju.code = 'thuju'

----------------
-- Stats
----------------
Thuju.health = 150
Thuju.damage = 15
Thuju.range = 32
Thuju.attackSpeed = 1.3
Thuju.speed = 35

Thuju.cost = 12


----------------
-- Upgrades
----------------
Thuju.upgrades = {
  wardofthorns = {
    level = 0,
    costs = {35, 60, 100, 150, 250},
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
    costs = {45, 75, 115, 165, 225},
    name = 'Tenacity',
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
      local healthIncreases = {[0] = 0, 50, 100, 150, 250, 350}
      local increase = healthIncreases[self.level]
      unit.health = unit.health + increase
      unit.maxHealth = unit.maxHealth + increase
    end
  },
  impenetrablehide = {
    level = 0,
    costs = {50, 75, 110, 155, 210},
    name = 'Impenetrable Hide',
    description = 'Thuju hardens his body when he is struck.  He takes reduced damage from all sources for 3 seconds, stacking multiple times.',
    values = {
      [1] = '5% damage reduction, stacking up to 3 times',
      [2] = '6% damage reduction, stacking up to 4 times',
      [3] = '7% damage reduction, stacking up to 5 times',
      [4] = '8% damage reduction, stacking up to 6 times',
      [5] = '10% damage reduction, stacking up to 7 times'
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('impenetrablehide')
      end
    end
  },
  taunt = {
    level = 0,
    costs = {80, 160, 240},
    prerequisites = {wardofthorns = 3, tenacity = 3},
    name = 'Taunt',
    description = 'Thuju beats his chest, forcing nearby enemies to attack him for 3 seconds.',
    values = {
      [1] = '100 range, 12 second cooldown',
      [2] = '150 range, 10 second cooldown',
      [3] = '200 range, 8 second cooldown'
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('taunt')
      end
    end
  },
  tremor = {
    level = 0,
    costs = {80, 160, 240},
    prerequisites = {tenacity = 3, impenetrablehide = 3},
    name = 'Tremor',
    description = 'Thuju slams the ground in the direction he is facing, causing the tectonic plates of the Earth to erupt in front of him.  Any units unfortunate enough to be caught in the area of impact take damage and are stunned.',
    values = {
      [1] = '100 range, 30 damage, .5s stun',
      [2] = '150 range, 50 damage, 1s stun',
      [3] = '175 range, 80 damage, 1.5s stun'
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
