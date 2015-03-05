local Kuju = {}
Kuju.name = 'Kuju'
Kuju.description = 'An ice witch who is great at stopping enemies in their tracks with powerful slows and cold magic.'

----------------
-- Stats
----------------
Kuju.health = 65
Kuju.damage = 9
Kuju.range = 150
Kuju.attackSpeed = 1.3
Kuju.speed = 35
Kuju.cost = 10

----------------
-- Upgrades
----------------
Kuju.upgrades = {
  frozenorb = {
    level = 0,
    maxLevel = 5,
    costs = {100, 150, 200, 250, 300},
    name = 'Frozen Orb',
    description = 'Kuju sends out a chilling orb that damages the first enemy struck.  The targeted is also Chilled for 1.5 seconds, reducing movement and attack speed by 40%.',
    x = -1,
    y = 0,
    values = {
      [1] = '0.5 damage per spirit, 7 second cooldown',
      [2] = '1.0 damage per spirit, 6 second cooldown',
      [3] = '1.5 damage per spirit, 5 second cooldown',
      [4] = '2.0 damage per spirit, 4 second cooldown',
      [5] = '2.5 damage per spirit, 3 second cooldown',
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('frozenorb')
      end
    end
  },
  shiverarmor = {
    level = 0,
    maxLevel = 5,
    costs = {100, 150, 200, 250, 300},
    name = 'Shiver Armor',
    description = 'Kuju enchants Muju\'s robes with powerful cold magic for a period of time.  Whenever Muju is struck, he deals damage to the attacker.  10 second cooldown.',
    x = 0,
    y = 0,
    values = {
      [1] = '30 damage, 4 second duration',
      [2] = '45 damage, 5 second duration',
      [3] = '60 damage, 6 second duration',
      [4] = '75 damage, 7 second duration',
      [5] = '90 damage, 8 second duration',
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('shiverarmor')
      end
    end
  },
  frostbite = {
    level = 0,
    maxLevel = 5,
    costs = {100, 150, 200, 250, 300},
    name = 'Frostbite',
    description = 'Kuju freezes an area of ground.  Every second, enemies in the area take damage.  Enemies take more damage the longer they stay in the zone.  20 second cooldown.',
    x = 1,
    y = 0,
    values = {
      [1] = '6 damage per second per second, 3 second duration',
      [2] = '8 damage per second per second, 4 second duration',
      [3] = '10 damage per second per second, 5 second duration',
      [4] = '12 damage per second per second, 6 second duration',
      [5] = '14 damage per second per second, 7 second duration',
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('frostbite')
      end
    end
  },
  shatter = {
    level = 0,
    maxLevel = 1,
    costs = {350},
    prerequisites = {frozenorb = 1},
    name = 'Shatter',
    description = 'Frozen Orb shatters on contact, damaging and chilling enemies behind the original target at 50% effectiveness.',
    x = -1,
    y = 1,
    connectedTo = {'frozenorb'},
    values = {
      [1] = 'Shatters',
    }
  },
  crystallize = {
    level = 0,
    maxLevel = 3,
    costs = {200, 300, 400},
    prerequisites = {shiverarmor = 1},
    name = 'Crystallize',
    description = 'Shiver Armor also has a chance to encase the attacker in ice, stunning it for 2 seconds.',
    x = 0,
    y = 1,
    connectedTo = {'shiverarmor'},
    values = {
      [1] = '20% stun chance',
      [2] = '35% stun chance',
      [3] = '50% stun chance'
    }
  },
  tundra = {
    level = 0,
    maxLevel = 1,
    costs = {350},
    prerequisites = {frostbite = 1},
    name = 'Tundra',
    description = 'The area of effect of frostbite is doubled.',
    x = 1,
    y = 1,
    connectedTo = {'frostbite'},
    values = {
      [1] = '+100% size'
    }
  },
  avalanche = {
    level = 0,
    maxLevel = 1,
    costs = {350},
    prerequisites = {shatter = 1},
    name = 'Avalanche',
    description = 'Frozen Orb is conjured with the force of an avalanche, knocking enemies back.',
    x = -1,
    y = 2,
    connectedTo = {'shatter'},
    values = {
      [1] = 'Knockback'
    }
  },
  frostnova = {
    level = 0,
    maxLevel = 1,
    costs = {500},
    prerequisites = {crystallize = 1},
    name = 'Frost Nova',
    description = 'If Muju dies while Shiver Armor is active, he will emit a powerful ring of frost that damages enemies for an amount equal to the current damage of Shiver Armor.',
    x = 0,
    y = 2,
    connectedTo = {'crystallize'},
    values = {
      [1] = 'Frost Nova'
    }
  },
  brainfreeze = {
    level = 0,
    maxLevel = 1,
    costs = {350},
    prerequisites = {tundra = 1},
    levelRequirement = 10,
    name = 'Brain Freeze',
    description = 'Frostbite sabotages its victims\' mental capacities.  Any enemies caught within Frostbite are unable to use special abilities.',
    x = 1,
    y = 2,
    connectedTo = {'tundra'},
    values = {
      [1] = 'Silences enemies',
    }
  },
  windchill = {
    level = 0,
    maxLevel = 3,
    costs = {500, 500, 500},
    prerequisites = {},
    name = 'Windchill',
    description = 'Kuju\'s attacks slow enemies and deal extra damage based on her spirit.',
    x = -1,
    y = 3,
    values = {
      [1] = '0.4 damage per spirit, 20% slow for .5 seconds',
      [2] = '0.6 damage per spirit, 40% slow for .75 seconds',
      [3] = '0.8 damage per spirit, 60% slow for 1 second',
    }
  },
  wintersblight = {
    level = 0,
    maxLevel = 3,
    costs = {500, 750, 1000},
    prerequisites = {avalanche = 1, brainfreeze = 1},
    name = 'Winter\'s Blight',
    description = 'All spell hits from Kuju deal extra damage based on the target\'s current health.',
    x = 0,
    y = 3,
    connectedTo = {'avalanche', 'brainfreeze'},
    values = {
      [1] = '8% current health damage',
      [2] = '16% current health damage',
      [3] = '24% current health damage',
    }
  },
  veinsofice = {
    level = 0,
    maxLevel = 1,
    costs = {1000},
    prerequisites = {},
    name = 'Veins of Ice',
    description = 'Kuju\'s spirit is increased by a percentage.',
    x = 1,
    y = 3,
    values = {
      [1] = '20% increased spirit'
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit.spirit = unit.spirit + (unit.spirit * .2)
      end
    end
  }
}

Kuju.attackSpell = 'kujuattack'

return Kuju
