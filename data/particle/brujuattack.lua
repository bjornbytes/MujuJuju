local BrujuAttack = class()
BrujuAttack.image = data.media.graphics.particles.smoke
BrujuAttack.max = 256
BrujuAttack.blendMode = 'additive'

BrujuAttack.options = {}
BrujuAttack.options.particleLifetime = {.25, .5}
BrujuAttack.options.colors = {{80, 200, 40, 100}, {80, 200, 40, 0}}
BrujuAttack.options.sizes = {1, 0}
BrujuAttack.options.sizeVariation = .1
BrujuAttack.options.areaSpread = {'normal', 4, 4}
BrujuAttack.options.spin = {-2, 2}
BrujuAttack.options.rotation = {0, 2 * math.pi}
BrujuAttack.options.linearAcceleration = {0, -1000, 0, -2000}

return BrujuAttack
