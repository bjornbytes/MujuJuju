local Kuju = {}
Kuju.name = 'Kuju'
Kuju.description = 'Yay Kuju.'

----------------
-- Stats
----------------
Kuju.health = 60
Kuju.damage = 10
Kuju.range = 145
Kuju.attackSpeed = 1.5
Kuju.speed = 30

Kuju.healthScaling = {6, 1}
Kuju.damageScaling = {.6, 1.05}

Kuju.attackSpell = 'kujuattack'

Kuju.startingAbilities = {'frozenorb'}

return Kuju
