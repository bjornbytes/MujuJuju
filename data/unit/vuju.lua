local Vuju = {}
Vuju.name = 'Vuju'
Vuju.description = 'Yay Vuju.'

----------------
-- Stats
----------------
Vuju.health = 65
Vuju.damage = 8
Vuju.range = 125
Vuju.attackSpeed = 1.5
Vuju.speed = 40

Vuju.healthScaling = {6, 1}
Vuju.damageScaling = {.5, 1.0}

Vuju.attackSpell = 'vujuattack'

Vuju.startingAbilities = {'teleport', 'puppetize'}

return Vuju
