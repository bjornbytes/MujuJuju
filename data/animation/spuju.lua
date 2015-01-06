local Spuju = extend(Animation)
Spuju.code = 'spuju'

Spuju.scale = .5
Spuju.offsety = 48
Spuju.default = 'spawn'
Spuju.states = {}

Spuju.states.spawn = {
  priority = 5,
  speed = 1
}

Spuju.states.idle = {
  priority = 1,
  loop = true,
  speed = .25
}

Spuju.states.walk = {
  priority = 1,
  loop = true,
  speed = .25
}

Spuju.states.attack = {
  priority = 1,
  loop = true,
  speed = .34
}

Spuju.states.death = {
  priority = 5,
  speed = .34
}

return Spuju
