local Spuju = {}
Spuju.code = 'spuju'
Spuju.name = 'Spuju'
Spuju.description = 'Yay Spuju.'

----------------
-- Stats
----------------
Spuju.health = 50
Spuju.damage = 10
Spuju.range = 175
Spuju.attackSpeed = 1.45
Spuju.speed = 20

Spuju.healthScaling = {6, .9}
Spuju.damageScaling = {1.1, .9}

Spuju.attackSpell = 'spujuskull'

Spuju.startingAbilities = {'fear'}

return Spuju
