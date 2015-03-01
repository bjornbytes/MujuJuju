local Buju = {}
Buju.name = 'Buju'
Buju.description = 'A shadow warrior able to phase into and out of the juju realm.  Buju excels in moving quickly, dealing high damage, and avoiding attacks.'

----------------
-- Stats
----------------
Buju.health = 65
Buju.damage = 20
Buju.range = 30
Buju.attackSpeed = 1.2
Buju.speed = 55
Buju.cost = 10

Buju.attackParticleCount = 10

----------------
-- Upgrades
----------------
Buju.upgrades = {
  ambush = {
    level = 0,
    maxLevel = 1,
    costs = {250},
    levelRequirement = 1,
    name = 'Ambush',
    description = 'Buju vanishes into the Juju Realm only to appear when an enemy is in range.',
    x = -1,
    y = 0,
    values = {
      [1] = 'Vanish and attack.'
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit.buffs:add('ambush')
      end
    end
  },
  rend = {
    level = 0,
    maxLevel = 2,
    costs = {100, 200},
    levelRequirement = 1,
    name = 'Rend',
    description = 'Buju sharply brings his spikes down into an enemy leaving it bleeding.',
    x = 0,
    y = 0,
    values = function(self, level, class)
      if level == 0 then return '' end
      local rend = data.ability.buju.rend
      local spirit = class.attributes.flow * config.attributes.flow.spirit
      return math.round(rend.baseDamages[level] * 100) .. '% base damage and ' .. rend.dots[level] .. ' {green}(+' .. math.round(rend.spiritRatio * spirit) .. '){white} damage per second for 3 seconds.'
    end,
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('rend')
      end
    end
  },
  darkrend = {
    level = 0,
    maxLevel = 4,
    costs = {50, 100, 150, 200},
    levelRequirement = 10,
    prerequisites = {rend = 1},
    connectedTo = {'rend'},
    name = 'Dark Rend',
    description = 'The Juju Realm\'s power coarses through Buju empowering his rend.',
    x = 0,
    y = 2,
    values = {
      [1] = 'Rend now bleeds 25% more damage per second for 3 seconds while in the Juju Realm.',
      [2] = 'Rend now bleeds 50% more damage per second for 3 seconds while in the Juju Realm.',
      [3] = 'Rend now bleeds 75% more damage per second for 3 seconds while in the Juju Realm.',
      [4] = 'Rend now bleeds 100% more damage per second for 3 seconds while in the Juju Realm.'
    }
  },
  twinblades = {
    level = 0,
    maxLevel = 1,
    costs = {500},
    levelRequirement = 20,
    prerequisites = {darkrend = 2},
    connectedTo = {'darkrend'},
    name = 'Twin Blades',
    description = 'Buju now swipes both of his blades rending enemies in range.',
    x = 0,
    y = 4,
    values = {
      [1] = 'Rend one extra target.'
    }
  },
  ghostarmor = {
    level = 0,
    maxLevel = 5,
    costs = {50, 100, 150, 200, 250},
    levelRequirement = 1,
    name = 'Ghost Armor',
    description = 'Buju\'s armor gives him a chance to evade attacks while in the Juju Realm.',
    x = 1,
    y = 0,
    values = {
      [1] = '10% dodge chance',
      [2] = '20% dodge chance',
      [3] = '30% dodge chance',
      [4] = '40% dodge chance',
      [5] = '50% dodge chance',
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit.buffs:add('ghostarmor')
      end
    end
  },
  voidmetal = {
    level = 0,
    maxLevel = 2,
    costs = {300, 300},
    levelRequirement = 5,
    prerequisites = {ghostarmor = 3},
    connectedTo = {'ghostarmor'},
    name = 'Void Metal',
    description = 'Buju\'s armor is fortified with void metal, giving him a chance to avoid crowd control effects in the Juju Realm',
    x = 1,
    y = 1,
    values = {
      [1] = '40% chance to avoid crowd control',
      [2] = '60% chance to avoid crowd control'
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit.buffs:add('voidmetal')
      end
    end
  },
  temperedbastion = {
    level = 0,
    maxLevel = 1,
    costs = {1000},
    levelRequirement = 10,
    prerequisites = {voidmetal = 2},
    connectedTo = {'voidmetal'},
    name = 'Tempered Bastion',
    description = 'Buju\'s armor is magically infused with light-bending bastion. All enhancements are available outside of the Juju Realm.',
    x = 1,
    y = 3,
    values = {
      [1] = 'Can now benefit from Ghost Armor and Void Metal outside of the Juju Realm.'
    }
  },
  victoryrush = {
    level = 0,
    maxLevel = 3,
    costs = {500, 500, 500},
    levelRequirement = 20,
    prerequisites = {deathwish = 3},
    connectedTo = {'deathwish'},
    name = 'Victory Rush',
    description = 'If Buju receives the killing blow, he becomes quicker.',
    x = -1,
    y = 4,
    values = {
      [1] = 'Speed increased by 40% for 3 seconds.',
      [2] = 'Speed increased by 80% for 4 seconds.',
      [3] = 'Speed increased by 120% for 5 seconds.'
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('victoryrush')
      end
    end
  },
  empoweredstrikes = {
    level = 0,
    maxLevel = 3,
    costs = {100, 200, 300},
    levelRequirement = 5,
    name = 'Empowered Strikes',
    description = 'Buju increases his attack speed with each strike.',
    x = -1,
    y = 1,
    values = {
      [1] = '10% faster attack speed. Up to 2 stacks.',
      [2] = '15% faster attack speed. Up to 3 stacks.',
      [3] = '20% faster attack speed. Up to 4 stacks.'
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('empoweredstrikes')
      end
    end
  },
  deathwish = {
    level = 0,
    maxLevel = 3,
    costs = {200, 400, 600},
    levelRequirement = 15,
    prerequisites = {empoweredstrikes = 3},
    connectedTo = {'empoweredstrikes'},
    name = 'Death Wish',
    description = 'When Buju\'s target is below 20% health, Buju has a chance to execute the target.',
    x = -1,
    y = 3,
    values = {
      [1] = '40% chance to execute the target.',
      [2] = '60% chance to execute the target.',
      [3] = '80% chance to execute the target.'
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('deathwish')
      end
    end
  },
  grimreaper = {
    level = 0,
    maxLevel = 1,
    costs = {1500},
    levelRequirement = 20,
    name = 'Grim Reaper',
    description = 'On death, Buju seeks revenge on his target in his void form.',
    x = 1,
    y = 4,
    values = {
      [1] = 'Buju\'s void form lasts for 5 seconds.'
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit.buffs:add('grimreaper')
      end
    end
  }
}


return Buju
