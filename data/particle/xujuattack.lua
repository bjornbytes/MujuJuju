local XujuAttack = class()
XujuAttack.image = data.media.graphics.particles.star
XujuAttack.max = 256
XujuAttack.blendMode = 'additive'

XujuAttack.options = {}
XujuAttack.options.particleLifetime = {.4}
XujuAttack.options.colors = {{200, 100, 255, 100}, {200, 100, 255, 0}}
XujuAttack.options.sizes = {.5, 0}
XujuAttack.options.sizeVariation = .1
XujuAttack.options.speed = {50, 50}
XujuAttack.options.linearDamping = {1, 1}
XujuAttack.options.relativeRotation = true
XujuAttack.options.spread = 2 * math.pi
--XujuAttack.options.tangentialAcceleration = {-2000, 2000}

return XujuAttack
