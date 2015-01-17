local Buju = {}
Buju.name = 'Buju'
Buju.description = 'A shadow warrior able to phase into and out of the juju realm.  Buju excels in moving quickly, dealing high damage, and avoiding attacks.'

----------------
-- Stats
----------------
Buju.health = 120
Buju.damage = 22
Buju.range = 16
Buju.attackSpeed = 1
Buju.speed = 55
Buju.flow = 1
Buju.cost = 5

----------------
-- Upgrades
----------------
Buju.upgrades = {
  --
}

----------------
-- Attributes
----------------
Buju.attributes = {
  vitality = {
    level = 0,
    amount = 12,
    stat = 'health',
  },
  strength = {
    level = 0,
    amount = 6,
    stat = 'damage',
  },
  agility = {
    level = 0,
    amount = 8,
    stat = 'speed'
  },
  flow = {
    level = 0,
    amount = .1,
    stat = 'flow'
  }
}

return Buju
