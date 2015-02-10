local BrujuAttack = class()
BrujuAttack.image = data.media.graphics.particles.smoke
BrujuAttack.max = 256
BrujuAttack.blendMode = 'additive'

BrujuAttack.options = {}
BrujuAttack.options.particleLifetime = {.125}
BrujuAttack.options.colors = {{80, 200, 40, 200}, {80, 200, 40, 0}}
BrujuAttack.options.sizes = {0, 2}
BrujuAttack.options.sizeVariation = .2
BrujuAttack.options.areaSpread = {'normal', 10, 10}
BrujuAttack.options.spin = {-2, 2}
BrujuAttack.options.rotation = {0, 2 * math.pi}

return BrujuAttack
