local Kuju = {}
Kuju.code = 'kuju'
Kuju.name = 'Kuju'
Kuju.description = 'Yay Kuju.'

----------------
-- Stats
----------------
Kuju.health = 60
Kuju.damage = 15
Kuju.range = 140
Kuju.attackSpeed = 1.3
Kuju.speed = 30

Kuju.healthScaling = {4, 1}
Kuju.damageScaling = {.8, 1}

Kuju.startingAbilities = {'frozenorb'}

return Kuju
