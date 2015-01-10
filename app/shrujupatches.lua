ShrujuPatches = class()

function ShrujuPatches:init()
  self.index = 1
  self.objects = {}
  self.harvestLevel = 0
  self.flowLevel = 0
  self.maxFlowLevel = math.ceil((config.biomes[ctx.biome].player.baseCooldown - config.biomes[ctx.biome].player.minCooldown) / data.shruju.flow.cdr)
end

function ShrujuPatches:update()
  table.with(self.objects, 'update')

  local conf = config.biomes[ctx.biome]
  if conf.shrujuPatches[self.index] and ctx.timer * tickRate > conf.shrujuPatches[self.index] then
    self:add()
  end
end

function ShrujuPatches:add()
  local x = ctx.map.width * (.2 + (self.index == 2 and .6 or 0))
  local patch = ShrujuPatch()
  patch.id = self.index
  table.merge({x = x}, patch)
  patch:activate()
  table.insert(self.objects, patch)
  ctx.hud.shrujuPatches[patch.id].patch = patch
  self.index = self.index + 1
end
