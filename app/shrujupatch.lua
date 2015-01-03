local g = love.graphics

Shrujus = {
  population = {
    time = 20,
    eat = function()
      local p = ctx.players:get(ctx.id)
      p.maxPopulation = p.maxPopulation + 1
    end
  },
  juju = {
    time = 15,
    eat = function()
      local p = ctx.players:get(ctx.id)
      p.juju = p.juju + love.math.random(10, 20)
			for i = 1, 40 do
				ctx.particles:add(JujuSex, {x = 52, y = 52})
			end
    end
  }
}

ShrujuPatch = class()

ShrujuPatch.width = 40
ShrujuPatch.height = 40
ShrujuPatch.depth = -1

function ShrujuPatch:activate(id)
  self.x = ctx.map.width * (.2 + (id == 2 and .6 or 0))
	self.y = ctx.map.height - ctx.map.groundHeight
  self.types = {'population', 'juju'}
  self.timer = 0
  self.slot = nil
  ctx.event:emit('view.register', {object = self})
end

function ShrujuPatch:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function ShrujuPatch:update()
  self.timer = timer.rot(self.timer, function()
    self.slot = self.growing
    self.growing = nil
  end)
end

function ShrujuPatch:draw()
  g.setColor(0, 0, 255, 200)
  g.rectangle('fill', self.x - self.width / 2, self.y - self.height, self.width, self.height)
end

function ShrujuPatch:grow(what)
  if not table.has(self.types, what) or self.growing or self.slot then return end
  self.timer = Shrujus[what].time
  self.growing = what
end

function ShrujuPatch:take()
  if not self.slot then return end
  local slot = self.slot
  self.slot = nil
  return slot
end
