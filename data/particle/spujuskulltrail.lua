local SpujuSkullTrail = class()
SpujuSkullTrail.image = data.media.graphics.particles.smoke
SpujuSkullTrail.max = 256
SpujuSkullTrail.blendMode = 'additive'

SpujuSkullTrail.options = {}
SpujuSkullTrail.options.particleLifetime = {.5, 1}
SpujuSkullTrail.options.colors = {{80, 200, 40, 100}, {80, 200, 40, 0}}
SpujuSkullTrail.options.sizes = {.7, 0}
SpujuSkullTrail.options.sizeVariation = .1
SpujuSkullTrail.options.areaSpread = {'normal', 5, 5}
SpujuSkullTrail.options.spin = {-1, 1}
SpujuSkullTrail.options.rotation = {0, 2 * math.pi}

return SpujuSkullTrail
