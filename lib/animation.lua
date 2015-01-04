Animation = class()

Animation.defaultMix = .2

function Animation:init(vars)
  table.merge(vars, self, true)

  self:initSpine(self.code)

  for i = 1, #self.states do
    table.each(self.states, function(state)
      if state.index ~= i then self.spine.animationStateData:setMix(self.states[i].name, state.name, self.defaultMix) end
    end)

    table.each(self.states[i].mix, function(time, to)
      self.spine.animationStateData:setMix(self.states[i].name, to, time)
    end)
  end

  self.event = Event()
  self.spine.animationState.onComplete = function() self.event:emit('complete', {state = self.state}) end
  self.spine.animationState.onEvent = function(_, data) self.event:emit('event', data) end

  self:set(self.default)
  self.speed = 1
  self.flipped = false
end

function Animation:draw(x, y, options)
  options = options or {}
  local skeleton, animationState = self.spine.skeleton, self.spine.animationState
  skeleton.x = x + (self.offsetx or 0)
  skeleton.y = y + (self.offsety or 0)
  skeleton.flipX = self.flipped
  if self.backwards then skeleton.flipX = not skeleton.flipX end
  if not options.noupdate then self:tick(delta) end
  animationState:apply(skeleton)
  skeleton:updateWorldTransform()
  skeleton:draw()

  if options.debug then
    table.each(self.spine.skeleton.slots, function(slot)
      slot:setAttachment(self.spine.skeleton:getAttachment(slot.data.name, slot.data.name .. '_bb'))
      self.spine.skeleton.flipY = true
    end)
    skeleton:updateWorldTransform()
    self.spine.skeletonBounds:update(self.spine.skeleton)
    love.graphics.setColor(255, 255, 255)
    for i = 1, #self.spine.skeletonBounds.polygons do
      love.graphics.polygon('line', self.spine.skeletonBounds.polygons[i])
    end
    table.each(self.spine.skeleton.slots, function(slot)
      slot:setAttachment(self.spine.skeleton:getAttachment(slot.data.name, slot.data.name))
      self.spine.skeleton.flipY = false
    end)
  end
end

function Animation:tick(delta)
  self.spine.animationState:update(delta * (self.state.speed or 1) * self.speed)
  self.spine.animationState:apply(self.spine.skeleton)
end

function Animation:set(name, options)
  if type(name) == 'number' and self.states[name] then name = self.states[name].name end
  if not name or not self.states[name] then return end
  options = options or {}

  local target = self.states[name]

  if self.state and self.state.name == target.name then return end
  if not options.force and self.state and self.state.priority > target.priority then return end

  self.state = target
  if self.spine.skeletonData:findAnimation(self.state.name) then
    self.spine.animationState:setAnimationByName(0, self.state.name, self.state.loop)
  end
end

function Animation:contains(x, y)
  table.each(self.spine.skeleton.slots, function(slot)
    slot:setAttachment(self.spine.skeleton:getAttachment(slot.data.name, slot.data.name .. '_bb'))
  end)

  self.spine.skeleton.flipY = true
  self.spine.skeleton:updateWorldTransform()
  self.spine.skeletonBounds:update(self.spine.skeleton)
  self.spine.skeleton.flipY = false
  local contains = self.spine.skeletonBounds:containsPoint(x, y)

  table.each(self.spine.skeleton.slots, function(slot)
    slot:setAttachment(self.spine.skeleton:getAttachment(slot.data.name, slot.data.name))
  end)

  return contains
end

function Animation:initSpine(name)
	local json = spine.SkeletonJson.new()
  json.scale = self.scale

	local skeletonData = json:readSkeletonDataFile('media/skeletons/' .. name .. '/' .. name .. '.json')

	local skeleton = spine.Skeleton.new(skeletonData)
	skeleton.createImage = function(_, attachment)
		return love.graphics and love.graphics.newImage('media/skeletons/' .. name .. '/' .. attachment.name .. '.png')
	end
	skeleton:setToSetupPose()
  local skeletonBounds = spine.SkeletonBounds.new()
  local animationStateData = spine.AnimationStateData.new(skeletonData)
  local animationState = spine.AnimationState.new(animationStateData)

  self.spine = {
    json = json,
    skeletonData = skeletonData,
    skeleton = skeleton,
    skeletonBounds = skeletonBounds,
    animationStateData = animationStateData,
    animationState = animationState
  }
end

function Animation:on(...)
  return self.event:on(...)
end
