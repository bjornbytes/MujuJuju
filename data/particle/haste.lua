local Haste = class()
Haste.image = data.media.graphics.particles.line
Haste.max = 256
Haste.blendMode = 'additive'

Haste.options = {}
Haste.options.particleLifetime = {.5}
Haste.options.colors = {{150, 255, 255, 180}, {150, 255, 255, 0}}
Haste.options.sizes = {.6, .2}
Haste.options.areaSpread = {'normal', 4, 4}
Haste.options.speed = {80, 80}
Haste.options.linearDamping = {1, 2}

return Haste
