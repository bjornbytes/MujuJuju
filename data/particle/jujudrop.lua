local JujuDrop = class()
JujuDrop.image = data.media.graphics.particles.softCircle
JujuDrop.max = 1024
JujuDrop.blendMode = 'additive'

JujuDrop.options = {}
JujuDrop.options.particleLifetime = {.5, 1.5}
JujuDrop.options.colors = {{100, 200, 0, 150}, {100, 200, 0, 0}}
JujuDrop.options.sizes = {.25, 0}
JujuDrop.options.sizeVariation = .75
JujuDrop.options.speed = {40, 60}
JujuDrop.options.tangentialAcceleration = {1, 1.5}
JujuDrop.options.spread = math.pi * 2
JujuDrop.options.areaSpread = {'normal', 5, 5}
JujuDrop.options.linearDamping = {1, 5}
JujuDrop.options.linearAcceleration = {0, 0, 0, 40}

return JujuDrop
