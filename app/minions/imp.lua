require('app/minions/minion')

Imp = extend(Minion)

Imp.code = 'zuju'
Imp.cost = 10
Imp.cooldown = 5

Imp.speed = 60
Imp.damage = 35
Imp.fireRate = 1.7
Imp.attackRange = Imp.width / 2
Imp.maxHealth = 70
