local MagicShruju = class()
MagicShruju.image = data.media.graphics.particles.star
MagicShruju.max = 1024
MagicShruju.blendMode = 'additive'

MagicShruju.options = {}
MagicShruju.options.particleLifetime = {.5, 1.5}
MagicShruju.options.colors = {{160, 100, 255}, {160, 100, 255, 0}}
MagicShruju.options.sizes = {.16, 0}
MagicShruju.options.sizeVariation = .5
MagicShruju.options.spread = 2 * math.pi
MagicShruju.options.linearAcceleration = {-20, -20, 20, 20}
MagicShruju.options.areaSpread = {'normal', 10, 10}
MagicShruju.options.spin = {-.8, .8}
MagicShruju.options.radialAcceleration = {-.1, .1}

return MagicShruju
