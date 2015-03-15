local Xuju = {}
Xuju.name = 'Xuju'
Xuju.description = 'A shadow warrior able to phase into and out of the juju realm.  Xuju excels in moving quickly, dealing high damage, and avoiding attacks.'

----------------
-- Stats
----------------
Xuju.health = 65
Xuju.damage = 20
Xuju.range = 30
Xuju.attackSpeed = 1.2
Xuju.speed = 55
Xuju.spirit = 0
Xuju.haste = 1
Xuju.cost = 10

Xuju.attackParticleCount = 10
Xuju.attackParticleBone = 'region_righthand'

----------------
-- Upgrades
----------------
Xuju.upgrades = {
  shadowrush = {
    level = 0,
    maxLevel = 3,
    costs = {100, 150, 200},
    name = 'Shadow Rush',
    description = 'Xuju leaps through the shadows, dashing towards a nearby target.',
    x = -1,
    y = 0,
    values = {
      [1] = '150 range, 12 second cooldown',
      [2] = '225 range, 8 second cooldown',
      [3] = '300 range, 4 second cooldown'
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
    description = 'Xuju has a chance to critically injure his opponent with his attacks, dealing double damage.',
    x = 0,
    y = 0,
    values = {
      [1] = '8% crit chance',
      [2] = '15% crit chance',
      [3] = '21% crit chance',
      [4] = '26% crit chance',
      [5] = '30% crit chance',
    },
    bonuses = function()
      return data.buff.rend:bonuses()
    end,
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
    description = 'Xuju has a chance to fade into the juju realm when struck by attacks, negating the damage completely.',
    x = 1,
    y = 0,
    values = {
      [1] = '10% dodge chance',
      [2] = '15% dodge chance',
      [3] = '20% dodge chance',
      [4] = '25% dodge chance',
      [5] = '30% dodge chance',
    },
    bonuses = function()
      return data.buff.ghostarmor:bonuses()
    end,
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
    description = 'Critical hits increase Xuju\'s attack speed for 5 seconds, stacking multiple times.',
    x = 0,
    y = 1,
    connectedTo = {'rend'},
    values = {
      [1] = '10% attack speed per stack, max 3 stacks',
      [2] = '12% attack speed per stack, max 4 stacks',
      [3] = '15% attack speed per stack, max 5 stacks'
    },
    bonuses = function()
      local bonuses = {}
      local rend = data.buff.rend
      if rend.runePerStack > 0 then
        table.insert(bonuses, {'Runes', math.round(rend.runePerStack * 100) .. '%', 'attack speed per stack'})
      end
      return bonuses
    end
  },

  voidmetal = {
    level = 0,
    maxLevel = 1,
    prerequisites = {ghostarmor = 3},
    costs = {300},
    name = 'Void Metal',
    description = 'Xuju has a chance to resist crowd control effects.',
    x = 1,
    y = 1,
    connectedTo = {'ghostarmor'},
    values = {
      [1] = '40% chance to ignore crowd control effects.'
    },
    bonuses = function()
      return data.buff.voidmetal:bonuses()
    end
  },

  deathwish = {
    level = 0,
    maxLevel = 3,
    prerequisites = {fury = 1},
    costs = {200, 200, 200},
    name = 'Death Wish',
    description = 'Xuju expertly identifies and exploits the weaknesses of crippled enemies.  Critical hit chance is doubled against enemies that are low on health.',
    connectedTo = {'fury'},
    x = 0,
    y = 2,
    values = {
      [1] = 'Crit chance doubled if target below 30% health',
      [2] = 'Crit chance doubled if target below 40% health',
      [3] = 'Crit chance doubled if target below 50% health'
    }
  },

  temperedbastion = {
    level = 0,
    maxLevel = 1,
    prerequisites = {voidmetal = 1},
    costs = {1000},
    name = 'Tempered Bastion',
    description = 'Xuju\'s armor is magically infused with light-bending bastion. The chance of effect for Ghost Armor and Void Metal are increased to 100% when Xuju is in the Juju Realm.',
    x = 1,
    y = 2,
    connectedTo = {'voidmetal'},
    values = {
      [1] = '100% chance for Ghost Armor and Void Metal'
    }
  },

  grimreaper = {
    level = 0,
    maxLevel = 1,
    costs = {1000},
    name = 'Grim Reaper',
    description = 'When Xuju dies, his void form seeks revenge on his attacker, killing them instantly.',
    x = -1,
    y = 3,
    values = {
      [1] = 'Sweet revenge'
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit.buffs:add('grimreaper')
      end
    end
  },

  ambush = {
    level = 0,
    maxLevel = 1,
    prerequisites = {shadowrush = 1},
    costs = {300},
    name = 'Ambush',
    description = 'When Muju enters the Juju Realm, Xuju disappears and appears behind the closest enemy, dealing damage.',
    x = -1,
    y = 1,
    connectedTo = {'shadowrush'},
    values = {
      [1] = '50 damage'
    },
    bonuses = function()
      return data.ability.xuju.ambush:bonuses()
    end,
    apply = function(self, unit)
      if self.level > 0 then
        unit:addAbility('ambush')
      end
    end
  },

  twinblades = {
    level = 0,
    maxLevel = 1,
    costs = {1500},
    name = 'Twin Blades',
    description = 'Xuju\'s attacks will also effect a second nearby enemy.',
    x = 0,
    y = 3,
    values = {
      [1] = 'Double hit'
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit.buffs:add('twinblades')
      end
    end
  },

  empoweredstrikes = {
    level = 0,
    maxLevel = 1,
    costs = {1500},
    name = 'Empowered Strikes',
    description = 'Every time Muju collects Juju, Xuju gains a charge of Empowered Strikes.  Empowered Strikes causes Xuju\'s next attack to deal increased damage and heal him for a percentage of the damage dealt.',
    x = 1,
    y = 3,
    values = {
      [1] = '+50% damage, +25% lifesteal, max 3 charges'
    },
    apply = function(self, unit)
      if self.level > 0 then
        unit.buffs:add('empoweredstrikes')
      end
    end
  }
}

Xuju.featured = {
  {'shadowrush', 'Dash through the shadows to strike enemies.'},
  {'rend', 'A chance to deal double damage on each attack.'},
  {'ghostarmor', 'A chance to evade attacks.'},
  {'twinblades', 'Strike twice with every hit.'}
}

return Xuju
