local Buju = {}
Buju.name = 'Buju'
Buju.description = 'A shadow warrior able to phase into and out of the juju realm.  Buju excels in moving quickly, dealing high damage, and avoiding attacks.'

----------------
-- Stats
----------------
Buju.width = 50
Buju.height = 110
Buju.health = 65
Buju.damage = 20
Buju.range = 16
Buju.attackSpeed = 1.2
Buju.speed = 55
Buju.cost = 5

----------------
-- Upgrades
----------------
Buju.upgrades = {
  ambush = {
    level = 0,
    maxLevel = 1,
    levelRequirement = 1,
    name = 'Ambush',
    description = 'Buju vanishes into the Juju Realm only to appear when an enemy is in range.',
    x = -1,
    y = 0,
    values = {
      [1] = 'Vanish and attack.'
    }
  },
  rend = {
    level = 0,
    maxLevel = 2,
    levelRequirement = 1,
    name = 'Rend',
    description = 'Buju sharply brings his spikes down into an enemy leaving it bleeding.',
    x = 0,
    y = 0,
    values = {
      [1] = '75 base damage and 35 Damage every second for 3 seconds.',
      [2] = '125 base damage and 45 damage every second for 3 seconds.'
    }
  },
  darkrend = {
    level = 0,
    maxLevel = 4,
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
    levelRequirement = 1,
    name = 'Ghost Armor',
    description = 'Buju\'s armor now resists slows and stuns in the Juju Realm',
    x = 1,
    y = 0,
    values = {
      [1] = '20% chance to resist slows and stuns.',
      [2] = '40% chance to resist slows and stuns.',
      [3] = '60% chance to resist slows and stuns.',
      [4] = '80% chance to resist slows and stuns.',
      [5] = '100% chance to resist slows and stuns.'
    }
  },
  voidmetal = {
    level = 0,
    maxLevel = 2,
    levelRequirement = 5,
    prerequisites = {ghostarmor = 3},
    connectedTo = {'ghostarmor'},
    name = 'Void Metal',
    description = 'Buju\'s armor is fortified with void metal, reducing damage taken in the Juju Realm.',
    x = 1,
    y = 1,
    values = {
      [1] = 'Absorbs 25% of incoming damage.',
      [2] = 'Absorbs 40% of incoming damage.'
    }
  },
  temperedbastion = {
    level = 0,
    maxLevel = 1,
    levelRequirement = 10,
    prerequisites = {voidmetal = 2},
    connectedTo = {'voidmetal'},
    name = 'Tempered Bastion',
    description = 'Buju\'s armor is magically infused with light-bending bastion. All enhancements are available outside of the Juju Realm.',
    x = 1,
    y = 2,
    values = {
      [1] = 'Can now benefit from Ghost Armor and Void Metal outside of the Juju Realm.'
    }
  },
  victoryrush = {
    level = 0,
    maxLevel = 2,
    levelRequirement = 20,
    prerequisites = {deathwish = 3},
    connectedTo = {'deathwish'},
    name = 'Victory Rush',
    description = 'If Buju receives the killing blow, he becomes quicker.',
    x = -1,
    y = 4,
    values = {
      [1] = 'Speed increased by 10% for 5 seconds.',
      [2] = 'Speed increased by 20% for 5 seconds.',
      [3] = 'Speed increased by 40% for 5 seconds.'
    }
  },
  empoweredstrikes = {
    level = 0,
    maxLevel = 3,
    levelRequirement = 5,
    name = 'Empowered Strikes',
    description = 'Critical strikes now give a 40% chance to increase attack speed.',
    x = -1,
    y = 1,
    values = {
      [1] = '20% faster attack speed for 2 seconds.',
      [2] = '30% faster attack speed for 2 seconds.',
      [3] = '40% faster attack speed for 2 seconds.'
    }
  },
  deathwish = {
    level = 0,
    maxLevel = 3,
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
    }
  },
  grimreaper = {
    level = 0,
    maxLevel = 1,
    levelRequirement = 20,
    name = 'Grim Reaper',
    description = 'On death, Buju seeks revenge on his target in his void form.',
    x = 1,
    y = 4,
    values = {
      [1] = 'Buju\'s void form lasts for 5 seconds.'
    }
  }
}


return Buju
