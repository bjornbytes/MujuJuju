local Frostbite = class()
Frostbite.image = data.media.graphics.particles.star
Frostbite.max = 32
Frostbite.blendMode = 'additive'

Frostbite.options = {}
Frostbite.options.particleLifetime = {.5, 1.5}
Frostbite.options.colors = {{120, 220, 255, 150}, {120, 220, 255, 0}}
Frostbite.options.sizes = {.25, 0}
Frostbite.options.sizeVariation = .5
Frostbite.options.speed = {50, 70}
Frostbite.options.spread = math.pi / 2
Frostbite.options.direction = {-math.pi / 2}
Frostbite.options.linearAcceleration = {-20, 300, 20, 400}
Frostbite.options.spin = {-.8, .8}
Frostbite.options.rotation = {0, 2 * math.pi}

return Frostbite
