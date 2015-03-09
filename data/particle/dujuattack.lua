local DujuAttack = class()
DujuAttack.image = data.media.graphics.particles.smoke
DujuAttack.max = 32
DujuAttack.blendMode = 'additive'

DujuAttack.options = {}
DujuAttack.options.particleLifetime = {.5}
DujuAttack.options.colors = {{150, 130, 100, 100}, {150, 130, 200, 0}}
DujuAttack.options.sizes = {.6, 1}
DujuAttack.options.sizeVariation = .1
DujuAttack.options.areaSpread = {'normal', 6, 6}
DujuAttack.options.rotation = {0, 2 * math.pi}

return DujuAttack
