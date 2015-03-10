HudDeadCampaign = class()

local g = love.graphics

function HudDeadCampaign:init(hud)
  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

  self.geometryFunctions = {
    deadOk = function()
      local u, v = hud.u, hud.v
      local w = u * .25
      local h = v * .1
      local x = u / 2 - w / 2
      local y = v - .15 * v - h
      return {x, y, w, h}
    end
  }

  self.deadOk = hud.gooey:add(Button, 'hud.dead.ok')
  self.deadOk.geometry = function() return self.geometry.deadOk end
  self.deadOk:on('click', function() self:endGame() end)
  self.deadOk.text = 'Finished'

  self.delay = 1
  self.timeFactor = 0
  self.prevTimeFactor = self.timeFactor
  self.soundTimer = 0
  self.soundRate = 2 / ls.tickrate
  self.alpha = 0
  self.prevAlpha = self.alpha
  self.bgAlpha = 0
  self.prevBgAlpha = self.bgAlpha
  self.medalFactors = {bronze = 0, silver = 0, gold = 0}
  self.prevMedalFactors = {bronze = 0, silver = 0, gold = 0}
  self.canvas = g.newCanvas(400, 400)

  local function getMousePosition()
    return ctx.view:frameMouseX(), ctx.view:frameMouseY()
  end

  self.deadOk.getMousePosition = getMousePosition
end

function HudDeadCampaign:update()
  if not ctx.ded then return end

  local u, v = ctx.hud.u, ctx.hud.v

  if not self.rewards then
    self.rewards = {}
    for i = 1, #ctx.rewards.runes do
      table.insert(self.rewards, {
        kind = 'rune',
        rune = ctx.rewards.runes[i],
        x = u * .5,
        prevx = u * .5
      })
    end

    for i = 1, #ctx.rewards.minions do
      local minion = ctx.rewards.minions[i]
      local reward = {
        kind = 'minion',
        minion = minion,
        x = u * .5,
        prevx = u * .5
      }

      local animationScales = {
        thuju = .55,
        bruju = 1.3,
        xuju = .55,
        kuju = .6
      }

      local animation = data.animation[minion]({scale = animationScales[minion]})
      animation:on('complete', function() animation:set('idle', {force = true}) end)
      reward.animation = animation

      table.insert(self.rewards, reward)
    end

    for i = 1, #ctx.rewards.hats do
      table.insert(self.rewards, {
        kind = 'hat',
        hat = ctx.rewards.hats[i],
        x = u * .5,
        prevx = u * .5
      })
    end
  end

  self.prevBgAlpha = self.bgAlpha
  self.bgAlpha = math.lerp(self.bgAlpha, 1, math.min(6 * ls.tickrate, 1))

  if ctx.backgroundSound:isPlaying() then
    ctx.backgroundSound:setVolume(math.max(ctx.backgroundSound:getVolume() - 2 * ls.tickrate, 0))
    if ctx.backgroundSound:getVolume() == 0 then
      ctx.backgroundSound:stop()
    end
  end

  self.delay = timer.rot(self.delay)
  if self.delay == 0 then
    self.prevAlpha = self.alpha
    self.alpha = math.lerp(self.alpha, 1, math.min(6 * ls.tickrate, 1))

    self.prevTimeFactor = self.timeFactor
    self.timeFactor = math.lerp(self.timeFactor, 1, 1 * ls.tickrate)

    local inc = .2 * u
    local medalX = .5 * u - (inc * (3 - 1) / 2)
    local rewardSize = .1 * v
    local rewardInc = rewardSize + .05 * v
    local countSoFar = 0
    for _, medal in pairs({'bronze', 'silver', 'gold'}) do
      if math.floor(ctx.timer * self.prevTimeFactor * ls.tickrate) >= config.medals[medal] then
        local kinds = {bronze = 'rune', silver = 'minion', gold = 'hat'}
        if self.rewards then
          for i = 1, #self.rewards do
            local reward = self.rewards[i]
            if reward.kind == kinds[medal] then
              countSoFar = countSoFar + 1
            end
          end
        end
      end
    end

    local rewardX = .5 * u - (rewardInc * (countSoFar - 1) / 2)
    for _, medal in pairs({'bronze', 'silver', 'gold'}) do
      if math.floor(ctx.timer * self.prevTimeFactor * ls.tickrate) >= config.medals[medal] then
        if self.medalFactors[medal] == 0 then
          ctx.particles:emit('upgrade', medalX, .37 * v, 20)
          ctx.sound:play('upgrade')
        end
        self.prevMedalFactors[medal] = self.medalFactors[medal]
        self.medalFactors[medal] = math.lerp(self.medalFactors[medal], 1, math.min(10 * ls.tickrate, 1))

        local kinds = {bronze = 'rune', silver = 'minion', gold = 'hat'}
        if self.rewards then
          for i = 1, #self.rewards do
            local reward = self.rewards[i]
            if reward.kind == kinds[medal] then
              reward.prevx = reward.x
              reward.x = math.lerp(reward.x, rewardX, 12 * ls.tickrate)
              rewardX = rewardX + rewardInc
            end
          end
        end
      end
      medalX = medalX + inc
    end

    self.soundTimer = timer.rot(self.soundTimer)
    if self.soundTimer == 0 and math.floor(ctx.timer * self.prevTimeFactor * ls.tickrate) ~= math.floor(ctx.timer * self.timeFactor * ls.tickrate) then
      ctx.sound:play('juju1', function(sound)
        sound:setPitch(.5 + self.timeFactor)
        sound:setVolume(.5 + self.timeFactor * .25)
      end)
      self.soundTimer = 1 / self.soundRate
    end
  end
end

function HudDeadCampaign:draw()
  if not ctx.ded then return end

  local u, v = ctx.hud.u, ctx.hud.v
  local bigFont = .09 * v
  local smallFont = .05 * v

  local alpha = math.lerp(self.prevAlpha, self.alpha, ls.accum / ls.tickrate)
  local bgAlpha = math.lerp(self.prevBgAlpha, self.bgAlpha, ls.accum / ls.tickrate)
  local timeFactor = math.lerp(self.prevTimeFactor, self.timeFactor, ls.accum / ls.tickrate)
  if self.timeFactor ~= 1 and math.round(ctx.timer * ls.tickrate) == math.round(ctx.timer * ls.tickrate * timeFactor) then
    self.timeFactor = 1
    timeFactor = 1
    ctx.sound:play('juju1', function(sound) sound:setPitch(2) end)
  end

  local x, y = .1 * u, .1 * v
  local padding = .05 * v

  g.setColor(0, 0, 0, 120 * bgAlpha)
  g.rectangle('fill', x, y, .8 * u, .8 * v)

  g.setColor(180, 255, 50)
  g.setFont('mesmerize', bigFont)
  local str = 'Game Over!'
  g.printShadow(str, x + padding, y + padding)

  if timeFactor > 0 then
    g.setColor(255, 255, 255)
    str = tostring(toTime(ctx.timer * ls.tickrate * timeFactor, true))
    g.printShadow(str, x + .8 * u - g.getFont():getWidth(str) - padding, y + padding)
  end

  local inc = .2 * u
  local medalX = .5 * u - (inc * (3 - 1) / 2)
  for _, medal in ipairs({'bronze', 'silver', 'gold'}) do
    local factor = math.lerp(self.prevMedalFactors[medal], self.medalFactors[medal], ls.accum / ls.tickrate)
    local size = .15 * v * (.8 + .2 * factor)
    local image = data.media.graphics.menu[medal]
    local scale = size / image:getHeight()
    local alpha = alpha * (.4 + .6 * factor)
    g.setColor(255 * alpha, 255 * alpha, 255 * alpha, 255 * alpha)
    g.draw(image, medalX, .4 * v, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
    medalX = medalX + inc
  end

  if self.rewards then
    local rewardSize = .1 * v
    for i = 1, #self.rewards do
      local reward = self.rewards[i]
      local medal = ({rune = 'bronze', minion = 'silver', hat = 'gold'})[reward.kind]
      local factor = math.lerp(self.prevMedalFactors[medal], self.medalFactors[medal], ls.accum / ls.tickrate)
      local x = math.lerp(reward.prevx, reward.x, ls.accum / ls.tickrate)
      g.setColor(255, 255, 255, 255 * factor)
      if reward.kind == 'rune' then
        g.drawRune(reward.rune, reward.x, .63 * v, rewardSize, rewardSize * .5)
      elseif reward.kind == 'minion' then
        local canvas = self.canvas
        local cw, ch = canvas:getDimensions()
        canvas:clear(0, 0, 0, 0)
        canvas:renderTo(function()
          local animation = reward.animation
          animation.spine.skeleton.a = factor
          animation:draw(cw / 2, ch / 2)
        end)
        local scale = (rewardSize / cw) * 3
        g.setColor(255, 255, 255)
        g.draw(self.canvas, reward.x, .63 * v, 0, scale, scale, cw / 2, ch / 2)
      elseif reward.kind == 'hat' then
        local image = data.media.graphics.hats[reward.hat]
        if image then
          local scale = rewardSize / math.max(image:getWidth(), image:getHeight())
          g.setColor(255, 255, 255, 255 * factor)
          g.draw(image, reward.x, .63 * v, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
        end
      end
    end
  end

  self.deadOk:draw()
end

function HudDeadCampaign:keypressed(key)
  if not ctx.ded then return end

  if key == 'return' then self:endGame() end
end

function HudDeadCampaign:mousemoved(mx, my)
  local u, v = ctx.hud.u, ctx.hud.v
  local rewardSize = .1 * v

  if self.rewards then
    for _, medal in pairs({'bronze', 'silver', 'gold'}) do
      if math.floor(ctx.timer * self.prevTimeFactor * ls.tickrate) >= config.medals[medal] then
        local kinds = {bronze = 'rune', silver = 'minion', gold = 'hat'}
        for i = 1, #self.rewards do
          local reward = self.rewards[i]
          if math.insideCircle(mx, my, reward.x, .63 * v, rewardSize / 2) and reward.kind == kinds[medal] then
            if reward.kind == 'rune' then
              ctx.hud.tooltip:setRuneTooltip(reward.rune)
            elseif reward.kind == 'minion' then
              ctx.hud.tooltip:setUnitTooltip(reward.minion, true)
            elseif reward.kind == 'hat' then
              ctx.hud.tooltip:setHatTooltip(reward.hat)
            end
          end
        end
      end
    end
  end
end

function HudDeadCampaign:endGame()
  Context:add(Menu, ctx.user, ctx.options, {page = ctx.mode, biome = ctx.biome, user = ctx.user, rewards = ctx.rewards})
  Context:remove(ctx)
end
