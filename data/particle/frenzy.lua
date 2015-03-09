local DamageReflect = class()
DamageReflect.image = data.media.graphics.particles.softCircle
DamageReflect.max = 256
DamageReflect.blendMode = 'additive'

DamageReflect.options = {}
DamageReflect.options.particleLifetime = {.4}
DamageReflect.options.colors = {{255, 255, 220, 20}, {255, 255, 220, 0}}
DamageReflect.options.sizes = {.4, .3}
DamageReflect.options.areaSpread = {'normal', 2, 2}

return DamageReflect
