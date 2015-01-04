local Huju = extend(Animation)
Huju.code = 'huju'

Huju.scale = .5
Huju.offsety = 64
Huju.default = 'spawn'
Huju.states = {}

Huju.states.spawn = {
  priority = 5,
  speed = 1
}

Huju.states.idle = {
  priority = 1,
  loop = true,
  speed = .4
}

Huju.states.walk = {
  priority = 1,
  loop = true,
  speed = .4
}

Huju.states.attack = {
  priority = 1,
  loop = true,
  speed = .8
}

Huju.states.death = {
  priority = 5,
  speed = .8
}

return Huju
