local BujuAttack = class()
BujuAttack.image = data.media.graphics.particles.star
BujuAttack.max = 256
BujuAttack.blendMode = 'additive'

BujuAttack.options = {}
BujuAttack.options.particleLifetime = {.4}
BujuAttack.options.colors = {{200, 100, 255, 100}, {200, 100, 255, 0}}
BujuAttack.options.sizes = {.5, 0}
BujuAttack.options.sizeVariation = .1
BujuAttack.options.speed = {50, 50}
BujuAttack.options.linearDamping = {1, 1}
BujuAttack.options.relativeRotation = true
BujuAttack.options.spread = 2 * math.pi
--BujuAttack.options.tangentialAcceleration = {-2000, 2000}

return BujuAttack
