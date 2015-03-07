local KujuAttack = class()
KujuAttack.image = data.media.graphics.particles.smoke
KujuAttack.max = 256
KujuAttack.blendMode = 'additive'

KujuAttack.options = {}
KujuAttack.options.particleLifetime = {.25, .5}
KujuAttack.options.colors = {{120, 220, 255, 150}, {120, 220, 255, 0}}
KujuAttack.options.sizes = {.6, 1.2}
KujuAttack.options.sizeVariation = .3
KujuAttack.options.areaSpread = {'normal', 6, 6}
KujuAttack.options.spin = {-2, 2}
KujuAttack.options.rotation = {0, 2 * math.pi}

return KujuAttack
