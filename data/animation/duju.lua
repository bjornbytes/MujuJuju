local Duju = extend(Animation)
Duju.code = 'duju'

Duju.scale = 1
Duju.default = 'idle'
Duju.backwards = true
Duju.states = {}

Duju.states.spawn = {
  priority = 5,
  speed = 1
}

Duju.states.idle = {
  priority = 1,
  loop = true,
  speed = 1
}

Duju.states.walk = {
  priority = 1,
  loop = true,
  speed = .5
}

Duju.states.attack = {
  priority = 1,
  loop = true,
  speed = .4
}

Duju.states.headbutt = {
  priority = 3,
  speed = .69,
}

Duju.states.charge = {
  priority = 3,
  speed = 1
}

Duju.states.death = {
  priority = 5,
  speed = 1
}

return Duju
