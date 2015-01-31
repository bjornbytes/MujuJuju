local Vuju = {}
Vuju.name = 'Vuju'
Vuju.description = 'Yay Vuju.'

----------------
-- Stats
----------------
Vuju.health = 65
Vuju.damage = 6
Vuju.range = 145
Vuju.attackSpeed = 1
Vuju.speed = 40

Vuju.healthScaling = {7, 1}
Vuju.damageScaling = {.5, 1.0}

Vuju.attackSpell = 'vujuattack'

Vuju.startingAbilities = {'teleport', 'puppetize'}

return Vuju
