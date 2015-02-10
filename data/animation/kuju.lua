local Kuju = extend(Animation)

Kuju.scale = .325
Kuju.offsety = 100
Kuju.backwards = true
Kuju.default = 'spawn'
Kuju.states = {}

Kuju.states.spawn = {
  priority = 5,
  speed = 1
}

Kuju.states.idle = {
  priority = 1,
  loop = true,
  speed = .21
}

Kuju.states.walk = {
  priority = 1,
  loop = true,
  speed = .73
}

Kuju.states.attack = {
  priority = 1,
  loop = true,
  speed = 1
}

Kuju.states.frozenorb = {
  priority = 3,
  speed = 1
}

Kuju.states.death = {
  priority = 5,
  speed = .8
}

return Kuju
