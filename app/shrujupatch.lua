local g = love.graphics

Shrujus = {
  population = {
    name = 'Population',
    time = 40,
    eat = function()
      local p = ctx.players:get(ctx.id)
      p.maxPopulation = p.maxPopulation + 1
    end
  },
  juju = {
    name = 'Juju',
    time = 30,
    eat = function()
      local p = ctx.players:get(ctx.id)
      p.juju = p.juju + love.math.random(10, 20)
			for i = 1, 40 do
				ctx.particles:add(JujuSex, {x = 52, y = 52})
			end
    end
  }
}

-- Amount is always between 0 and 1 and determines how strong the magic effect is.
ShrujuEffects = {
  wealth = {
    pickup = function(self)
      local p = ctx.players:get(ctx.id)
      self.amount = 1.9 + (.2 * self.strength)
      p.jujuRate = p.jujuRate * self.amount
    end,

    drop = function(self)
      p.jujuRate = p.jujuRate / self.amount
    end
  }
}

ShrujuPatch = class()

ShrujuPatch.width = 40
ShrujuPatch.height = 40
ShrujuPatch.depth = -1

function ShrujuPatch:activate()
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
    self:makeShruju()
  end)
end

function ShrujuPatch:draw()
  g.setColor(0, 0, 255, 200)
  g.rectangle('fill', self.x - self.width / 2, self.y - self.height, self.width, self.height)
  if self.slot then
    g.setLineWidth(2)
    g.setColor(0, 255, 0)
    g.rectangle('line', self.x - self.width / 2, self.y - self.height, self.width, self.height)
    g.setLineWidth(1)
  end
end

function ShrujuPatch:grow(what)
  if not self:playerNearby() or not table.has(self.types, what) or self.growing or self.slot then return end
  self.timer = Shrujus[what].time
  self.growing = what
end

function ShrujuPatch:take()
  if not self:playerNearby() or not self.slot then return end
  local slot = self.slot
  self.slot = nil
  return slot
end

function ShrujuPatch:playerNearby()
  local p = ctx.players:get(ctx.id)
  return not p.dead and math.abs(p.x - self.x) <= self.width / 2 + p.width / 2
end

function ShrujuPatch:makeShruju()
  if self.growing and not self.slot then
    local shruju = setmetatable({}, {__index = Shrujus[self.growing]})

    -- Randomly give it a random magical effect
    if love.math.random() < 1 then
      local effects = table.keys(ShrujuEffects)
      local effect = setmetatable({}, {__index = effects[love.math.random(1, #effects)]})
      effect.strength = love.math.random()
      shruju.effect = effect
    end

    self.slot = shruju
    self.growing = nil
  end
end
