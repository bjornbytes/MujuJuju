local Firefly = class()
Firefly.image = data.media.graphics.particles.softCircle
Firefly.max = 512
Firefly.blendMode = 'alpha'

Firefly.options = {}
Firefly.options.particleLifetime = {3, 10}
Firefly.options.colors = {{200, 255, 200, 0}, {200, 255, 200, 150}, {200, 255, 200, 0}}
Firefly.options.sizes = {0, .2, .1}
Firefly.options.sizeVariation = .75
Firefly.options.speed = {20, 50}
Firefly.options.tangentialAcceleration = {-50, 50}
Firefly.options.spread = 2 * math.pi
Firefly.options.linearDamping = {2, 5}
Firefly.options.areaSpread = {'normal', 400, 300}

return Firefly
