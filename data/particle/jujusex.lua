local JujuSex = class()
JujuSex.image = data.media.graphics.particles.softCircle
JujuSex.max = 1024
JujuSex.blendMode = 'additive'

JujuSex.options = {}
JujuSex.options.particleLifetime = {1}
JujuSex.options.colors = {{100, 200, 0, 200}, {100, 200, 0, 0}}
JujuSex.options.sizes = {.3, 0}
JujuSex.options.sizeVariation = .5
JujuSex.options.speed = {0, 250}
JujuSex.options.spread = math.pi * 2
JujuSex.options.linearDamping = {5, 5}
JujuSex.options.linearAcceleration = {0, 60, 0, 100}

return JujuSex
