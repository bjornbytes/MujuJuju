local Duju = {}
Duju.code = 'duju'
Duju.name = 'Duju'
Duju.description = 'Yay Duju.'

----------------
-- Stats
----------------
Duju.health = 50
Duju.damage = 16
Duju.range = 32
Duju.attackSpeed = 1.15
Duju.speed = 40

Duju.healthScaling = {4, 1.2}
Duju.damageScaling = {.5, 1}

Duju.startingAbilities = {'headbutt'}

return Duju
