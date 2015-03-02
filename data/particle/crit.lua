local Crit = class()
Crit.image = data.media.graphics.particles.star
Crit.max = 8
Crit.blendMode = 'additive'

Crit.options = {}
Crit.options.particleLifetime = {.75}
Crit.options.colors = {{255, 50, 50, 255}, {255, 50, 50, 50}}
Crit.options.sizes = {.8, 0}
Crit.options.sizeVariation = .5
Crit.options.speed = {150, 200}
Crit.options.linearDamping = {5, 10}
Crit.options.spread = 2 * math.pi
Crit.options.relativeRotation = true

return Crit
