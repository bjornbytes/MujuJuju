local Buju = extend(Animation)

Buju.scale = .3
Buju.offsety = 110
Buju.default = 'spawn'
Buju.states = {}

Buju.states.spawn = {
  priority = 5,
  speed = .75
}

Buju.states.idle = {
  priority = 1,
  loop = true,
  speed = 1
}

Buju.states.walk = {
  priority = 1,
  loop = true,
  speed = .73
}

Buju.states.attack = {
  priority = 1,
  loop = true,
  speed = 1
}

Buju.states.death = {
  priority = 5,
  speed = .8
}

return Buju
