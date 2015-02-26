local Thuju = extend(Animation)

Thuju.scale = .32
Thuju.offsety = 64
Thuju.default = 'spawn'
Thuju.states = {}

Thuju.states.spawn = {
  priority = 5,
  speed = .75
}

Thuju.states.idle = {
  priority = 1,
  loop = true,
  speed = .21
}

Thuju.states.walk = {
  priority = 1,
  loop = true,
  speed = .73
}

Thuju.states.attack = {
  priority = 1,
  loop = true,
  speed = 1
}

Thuju.states.taunt = {
  priority = 3,
  speed = 1
}

Thuju.states.tremor = {
  priority = 3,
  speed = 1
}

Thuju.states.death = {
  priority = 5,
  speed = .8
}

return Thuju
