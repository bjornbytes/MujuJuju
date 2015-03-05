local Crit = class()
Crit.image = data.media.graphics.particles.star
Crit.max = 256
Crit.blendMode = 'additive'

Crit.options = {}
Crit.options.particleLifetime = {.4}
Crit.options.colors = {{255, 100, 100, 100}, {255, 100, 100, 0}}
Crit.options.sizes = {1, 0}
Crit.options.sizeVariation = .1
Crit.options.speed = {100, 100}
Crit.options.linearDamping = {1, 1}
Crit.options.relativeRotation = true
Crit.options.spread = 2 * math.pi
--Crit.options.tangentialAcceleration = {-2000, 2000}

return Crit
