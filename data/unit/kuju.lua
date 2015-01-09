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
Kuju.attackSpeed = 1.5
Kuju.speed = 30

Kuju.healthScaling = {6, 1}
Kuju.damageScaling = {.8, .95}

Kuju.attackSpell = 'kujuattack'

Kuju.startingAbilities = {'frozenorb'}

return Kuju
