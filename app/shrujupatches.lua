ShrujuPatches = class()

function ShrujuPatches:init()
  self.objects = {}
  self.timer = self:start()
  self.harvestLevel = 0
end

function ShrujuPatches:update()
  table.with(self.objects, 'update')
  self.timer = timer.rot(self.timer, function()
    self:add()
    return self:start()
  end)
end

function ShrujuPatches:add()
  local x = ctx.map.width * (.2 + (self.index == 2 and .6 or 0))
  local patch = ShrujuPatch()
  patch.id = self.index
  table.merge({x = x}, patch)
  patch:activate()
  table.insert(self.objects, patch)
  ctx.hud.shrujuPatches[patch.id].patch = patch
end

function ShrujuPatches:start()
  self.index = self.index and (self.index + 1) or 1
  local config = config.biomes[ctx.biome].shrujuPatches[self.index]
  if config then
    return love.math.random(config.minTimer, config.maxTimer)
  end
end
