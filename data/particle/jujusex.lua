local JujuSex = class()
JujuSex.image = data.media.graphics.particles.softCircle
JujuSex.max = 1024
JujuSex.blendMode = 'additive'

JujuSex.options = {}
JujuSex.options.particleLifetime = {.5, 1.5}
JujuSex.options.colors = {{100, 200, 0}, {100, 200, 0, 0}}
JujuSex.options.sizes = {.25, .1}
JujuSex.options.sizeVariation = .5
JujuSex.options.speed = {100, 200}
JujuSex.options.direction = -math.pi / 2
JujuSex.options.spread = math.pi / 4
JujuSex.options.linearAcceleration = {0, 300, 0, 400}
JujuSex.options.linearDamping = {0, 0}

return JujuSex
