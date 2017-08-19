local Duju = {}
Duju.name = 'Duju'
Duju.description = 'Yay Duju.'

----------------
-- Stats
----------------
Duju.width = 75
Duju.health = 200
Duju.damage = 16
Duju.range = 12
Duju.attackSpeed = 1.15
Duju.speed = 40
Duju.spirit = 0
Duju.haste = 1

Duju.healthScaling = {9, 1}
Duju.damageScaling = {.5, 1}

Duju.startingAbilities = {'headbutt'}

return Duju
