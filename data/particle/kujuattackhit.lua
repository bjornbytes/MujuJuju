local KujuAttackHit = class()
KujuAttackHit.image = data.media.graphics.particles.linering
KujuAttackHit.max = 256
KujuAttackHit.blendMode = 'additive'

KujuAttackHit.options = {}
KujuAttackHit.options.particleLifetime = {.4}
KujuAttackHit.options.colors = {{120, 220, 255, 40}, {120, 220, 255, 0}}
KujuAttackHit.options.sizes = {.2, .6}
KujuAttackHit.options.sizeVariation = .3
KujuAttackHit.options.areaSpread = {'normal', 6, 6}
KujuAttackHit.options.spin = {-2, 2}
KujuAttackHit.options.rotation = {0, 2 * math.pi}

return KujuAttackHit
