local DamageReflect = class()
DamageReflect.image = data.media.graphics.particles.line
DamageReflect.max = 32

DamageReflect.options = {}
DamageReflect.options.particleLifetime = {.4}
DamageReflect.options.colors = {{255, 220, 200, 255}, {255, 220, 200, 0}}
DamageReflect.options.sizes = {.5, .5}
DamageReflect.options.relativeRotation = true
DamageReflect.options.spread = 2 * math.pi
DamageReflect.options.speed = {100, 100}
DamageReflect.options.radialAcceleration = {200, 200}
DamageReflect.options.linearAcceleration = {0, 500, 0, 500}
DamageReflect.options.areaSpread = {'normal', 10, 10}

return DamageReflect
