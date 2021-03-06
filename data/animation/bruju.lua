local Bruju = extend(Animation)

Bruju.scale = .5
Bruju.offsety = 55
Bruju.default = 'spawn'
Bruju.states = {}

Bruju.states.spawn = {
  priority = 5,
  speed = .85
}

Bruju.states.idle = {
  priority = 1,
  loop = true,
  speed = .3
}

Bruju.states.walk = {
  priority = 1,
  loop = true,
  speed = .73
}

Bruju.states.attack = {
  priority = 1,
  loop = true,
  speed = 1.6
}

Bruju.states.death = {
  priority = 5,
  speed = .8
}

return Bruju
