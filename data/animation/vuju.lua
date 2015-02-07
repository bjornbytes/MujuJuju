local Vuju = extend(Animation)

Vuju.scale = .3
Vuju.offsety = 64
Vuju.default = 'spawn'
Vuju.states = {}

Vuju.states.spawn = {
  priority = 5,
  speed = 1
}

Vuju.states.idle = {
  priority = 1,
  loop = true,
  speed = .66
}

Vuju.states.walk = {
  priority = 1,
  loop = true,
  speed = .92
}

Vuju.states.attack = {
  priority = 1,
  loop = true,
  speed = 1.62
}

Vuju.states.attack1 = {
  priority = 1,
  loop = true,
  speed = 1.62
}

Vuju.states.attack2 = {
  priority = 1,
  loop = true,
  speed = 1.08
}

Vuju.states.teleport = {
  priority = 3,
  speed = 1
}

Vuju.states.puppetize = {
  priority = 3,
  speed = 1
}

Vuju.states.death = {
  priority = 5,
  speed = .69
}

return Vuju
