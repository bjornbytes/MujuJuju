local Slow = class()
Slow.image = data.media.graphics.particles.line
Slow.max = 256
Slow.blendMode = 'additive'

Slow.options = {}
Slow.options.particleLifetime = {.5}
Slow.options.colors = {{255, 150, 150, 180}, {255, 150, 150, 0}}
Slow.options.sizes = {.6, .2}
Slow.options.areaSpread = {'normal', 4, 4}
Slow.options.speed = {40, 40}
Slow.options.linearDamping = {1, 2}

return Slow
