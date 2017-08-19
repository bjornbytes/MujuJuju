local Spuju = {}
Spuju.name = 'Spuju'
Spuju.description = 'Yay Spuju.'

----------------
-- Stats
----------------
Spuju.health = 160
Spuju.damage = 12
Spuju.range = 165
Spuju.attackSpeed = 1.5
Spuju.speed = 20
Spuju.spirit = 0
Spuju.haste = 1

Spuju.healthScaling = {9, .9}
Spuju.damageScaling = {.5, .85}

Spuju.attackSpell = 'spujuskull'

Spuju.startingAbilities = {'fear'}

return Spuju
