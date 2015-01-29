local GhostTrail = class()
GhostTrail.image = data.media.graphics.particles.smoke
GhostTrail.max = 256
GhostTrail.blendMode = 'additive'

GhostTrail.options = {}
GhostTrail.options.particleLifetime = {.5, 1}
GhostTrail.options.colors = {{255, 200, 255, 60}, {255, 255, 255, 0}}
GhostTrail.options.sizes = {1.5, 0}
GhostTrail.options.sizeVariation = .1
GhostTrail.options.areaSpread = {'normal', 5, 5}
GhostTrail.options.spin = {-1.5, 1.5}
GhostTrail.options.rotation = {0, 2 * math.pi}
GhostTrail.options.linearAcceleration = {0, 0, 0, 0}
GhostTrail.options.tangentialAcceleration = {-1, 1}

return GhostTrail
