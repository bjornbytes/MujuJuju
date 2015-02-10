local DujuAttack = class()
DujuAttack.image = data.media.graphics.particles.linering
DujuAttack.max = 256
DujuAttack.blendMode = 'additive'

DujuAttack.options = {}
DujuAttack.options.particleLifetime = {.12}
DujuAttack.options.colors = {{180, 50, 50, 100}, {180, 50, 50, 0}}
DujuAttack.options.sizes = {.4, .6, 0, 0}
DujuAttack.options.sizeVariation = .2
DujuAttack.options.spin = {-10, 10}
DujuAttack.options.rotation = {0, 2 * math.pi}

return DujuAttack
