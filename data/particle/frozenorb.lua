local KujuAttack = class()
KujuAttack.image = data.media.graphics.particles.ring
KujuAttack.max = 32
KujuAttack.blendMode = 'additive'

KujuAttack.options = {}
KujuAttack.options.particleLifetime = {.35}
KujuAttack.options.colors = {{120, 220, 255, 100}, {120, 220, 255, 0}}
KujuAttack.options.sizes = {.3, 1}
KujuAttack.options.sizeVariation = .2

return KujuAttack
