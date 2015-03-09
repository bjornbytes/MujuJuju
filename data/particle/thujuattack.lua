local ThujuAttack = class()
ThujuAttack.image = data.media.graphics.particles.smoke
ThujuAttack.max = 32
ThujuAttack.blendMode = 'additive'

ThujuAttack.options = {}
ThujuAttack.options.particleLifetime = {.5}
ThujuAttack.options.colors = {{150, 130, 100, 100}, {150, 130, 200, 0}}
ThujuAttack.options.sizes = {.6, 1}
ThujuAttack.options.sizeVariation = .1
ThujuAttack.options.areaSpread = {'normal', 6, 6}
ThujuAttack.options.rotation = {0, 2 * math.pi}

return ThujuAttack
