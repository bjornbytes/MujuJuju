local Duju = {}
Duju.name = 'Duju'
Duju.code = 'duju'

----------------
-- Stats
----------------
Duju.health = 65
Duju.damage = 18
Duju.range = 32
Duju.attackSpeed = 1.1
Duju.speed = 40

Duju.healthScaling = {4, 1.1}
Duju.damageScaling = {.5, 1}


----------------
-- Abilities
----------------
Duju.abilities = {'headbutt', 'charge'}

return Duju
