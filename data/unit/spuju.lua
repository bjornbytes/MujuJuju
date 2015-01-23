local Spuju = {}
Spuju.name = 'Spuju'
Spuju.description = 'Yay Spuju.'

----------------
-- Stats
----------------
Spuju.health = 50
Spuju.damage = 6
Spuju.range = 165
Spuju.attackSpeed = 1.5
Spuju.speed = 20
Spuju.flow = 1

Spuju.healthScaling = {6, .9}
Spuju.damageScaling = {.5, .9}

Spuju.attackSpell = 'spujuskull'

Spuju.startingAbilities = {'fear', 'blight'}

return Spuju
