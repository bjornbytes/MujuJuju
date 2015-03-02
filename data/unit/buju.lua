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
  shadowrush = {
    level = 0,
    maxLevel = 3,
    costs = {100, 150, 200},
    name = 'Shadow Rush',
    description = 'Buju leaps through the shadows, dashing towards a nearby target.',
    x = -1,
    y = 0,
    values = {
      [1] = '100 range, 10 second cooldown',
      [2] = '150 range, 8 second cooldown',
      [3] = '200 range, 6 second cooldown'
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('shadowrush')
      end
    end
  },
  rend = {
    level = 0,
    maxLevel = 5,
    costs = {100, 150, 200, 250, 300},
    name = 'Rend',
    description = 'Buju has a chance to critically injure his opponent with his attacks, dealing double damage.',
    x = 0,
    y = 0,
    values = {
      [1] = '8% crit chance',
      [2] = '15% crit chance',
      [3] = '21% crit chance',
      [4] = '26% crit chance',
      [5] = '30% crit chance',
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit.buffs:add('rend')
      end
    end
  },
  ghostarmor = {
    level = 0,
    maxLevel = 5,
    costs = {100, 150, 200, 250, 300},
    name = 'Ghost Armor',
    description = 'Buju has a chance to fade into the juju realm when struck by attacks, negating the damage completely.',
    x = 1,
    y = 0,
    values = {
      [1] = '10% dodge chance',
      [2] = '15% dodge chance',
      [3] = '20% dodge chance',
      [4] = '25% dodge chance',
      [5] = '30% dodge chance',
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit.buffs:add('ghostarmor')
      end
    end
  },
  fury = {
    level = 0,
    maxLevel = 3,
    prerequisites = {rend = 1},
    costs = {200, 300, 400},
    name = 'Fury',
    description = 'Critical hits increase Buju\'s attack speed for 5 seconds, stacking multiple times.',
    x = 0,
    y = 1,
    connectedTo = {'rend'},
    values = {
      [1] = '10% attack speed per stack, max 3 stacks',
      [2] = '12% attack speed per stack, max 4 stacks',
      [3] = '15% attack speed per stack, max 5 stacks'
    }
  },
  voidmetal = {
    level = 0,
    maxLevel = 1,
    prerequisites = {ghostarmor = 3},
    costs = {300},
    name = 'Void Metal',
    description = 'Buju has a chance to resist crowd control effects.',
    x = 1,
    y = 1,
    connectedTo = {'ghostarmor'},
    values = {
      [1] = '40% chance to ignore crowd control effects.'
    }
  },
  deathwish = {
    level = 0,
    maxLevel = 3,
    prerequisites = {fury = 1},
    costs = {200, 400, 600},
    name = 'Death Wish',
    description = 'Buju expertly identifies and exploits the weaknesses of crippled enemies.  Critical hit chance is doubled against enemies that are low on health.',
    connectedTo = {'fury'},
    x = 0,
    y = 2,
    values = {
      [1] = 'Crit chance doubled if target below 30% health',
      [1] = 'Crit chance doubled if target below 40% health',
      [1] = 'Crit chance doubled if target below 50% health'
    }
  },
  temperedbastion = {
    level = 0,
    maxLevel = 1,
    prerequisites = {voidmetal = 1},
    costs = {1000},
    name = 'Tempered Bastion',
    description = 'Buju\'s armor is magically infused with light-bending bastion. The chance of effect for Ghost Armor and Void Metal are increased to 100% when Buju is in the Juju Realm.',
    x = 1,
    y = 3,
    connectedTo = {'voidmetal'},
    values = {
      [1] = '100% chance for Ghost Armor and Void Metal'
    }
  },
  grimreaper = {
    level = 0,
    maxLevel = 1,
    prerequisites = {deathwish = 1},
    costs = {500},
    name = 'Grim Reaper',
    description = 'When Buju kills someone, something cool happens.',
    x = 0,
    y = 3,
    connectedTo = {'deathwish'},
    values = {
      [1] = 'Something cool'
    }
  },
  ambush = {
    level = 0,
    maxLevel = 1,
    prerequisites = {shadowrush = 3},
    costs = {1000},
    name = 'Ambush',
    description = 'When Muju enters the Juju Realm, Buju disappears and appears behind the closest enemy, dealing damage.',
    x = -1,
    y = 4,
    connectedTo = {'shadowrush'},
    values = {
      [1] = '50 damage'
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility()
      end
    end
  },
  twinblades = {
    level = 0,
    maxLevel = 1,
    costs = {1500},
    name = 'Twin Blades',
    description = 'Buju\'s attacks will also effect a second nearby enemy.',
    x = 0,
    y = 4,
    values = {
      [1] = 'Double hit'
    }
  },
  empoweredstrikes = {
    level = 0,
    maxLevel = 1,
    costs = {1500},
    name = 'Empowered Strikes',
    description = 'Every time Muju collects Juju, Buju gains a charge of Empowered Strikes.  Empowered Strikes causes Buju\'s next attack to deal increased damage and heal him for a percentage of the damage dealt.',
    x = 1,
    y = 4,
    values = {
      [1] = '+50% damage, +30% lifesteal, max 3 charges'
    }
  }
}

return Buju
