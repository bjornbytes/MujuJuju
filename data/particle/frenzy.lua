local Frenzy = class()
Frenzy.image = data.media.graphics.particles.softCircle
Frenzy.max = 256
Frenzy.blendMode = 'additive'

Frenzy.options = {}
Frenzy.options.particleLifetime = {.4}
Frenzy.options.colors = {{255, 255, 220, 20}, {255, 255, 220, 0}}
Frenzy.options.sizes = {.4, .3}
Frenzy.options.areaSpread = {'normal', 2, 2}

return Frenzy
