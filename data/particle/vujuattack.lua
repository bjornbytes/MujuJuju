local VujuAttack = class()
VujuAttack.image = data.media.graphics.particles.smoke
VujuAttack.max = 256

VujuAttack.options = {}
VujuAttack.options.particleLifetime = {1}
VujuAttack.options.colors = {{60, 60, 60, 180}, {60, 60, 60, 0}}
VujuAttack.options.sizes = {.25, 1}
VujuAttack.options.sizeVariation = .4
VujuAttack.options.areaSpread = {'normal', 8, 8}
VujuAttack.options.rotation = {0, 2 * math.pi}
VujuAttack.options.linearAcceleration = {-30, -100, 30, -200}

return VujuAttack
