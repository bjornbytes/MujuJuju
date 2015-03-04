local Xuju = extend(Animation)

Xuju.scale = .3
Xuju.offsety = 72
Xuju.default = 'spawn'
Xuju.states = {}

Xuju.states.spawn = {
  priority = 5,
  speed = .75
}

Xuju.states.idle = {
  priority = 1,
  loop = true,
  speed = 1
}

Xuju.states.walk = {
  priority = 1,
  loop = true,
  speed = .73
}

Xuju.states.attack = {
  priority = 1,
  loop = true,
  speed = 1
}

Xuju.states.death = {
  priority = 5,
  speed = .8
}

Xuju.states.vanish = {
  priority = 3,
  speed = .5
}

Xuju.states.rend = {
  priority = 3,
  speed = 1.3
}

return Xuju
