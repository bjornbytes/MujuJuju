Skeleton = class()

function Skeleton:init(data)
	local json = spine.SkeletonJson.new()

	self.data = json:readSkeletonDataFile(data.location)
	self.skeleton = spine.Skeleton.new(self.data)

	function self.skeleton:createImage(attachment)
		return love.graphics.newImage('media/skeletons/' .. data.name .. '/' .. attachment.name .. '.png')
	end

	self.x = data.x
	skeleton.x = data.x

	self.y = data.y
	skeleton.y = data.y

	skeleton:setToSetupPose()
end

Animator = class()

function Animator:init(data)
	if data then
		if getmetatable(data.skeleton).__index == Skeleton then
			self.skeleton = data.skeleton
			self.stateData = spine.AnimationStateData.new(data.skeleton)

			if data.mixes then
				table.each(data.mixes, function(mix)
					self.stateData:setMix(mix.from, mix.to, mix.time)
				end)
			end

			self.state = spine.AnimationState.new(self.stateData)
		else
			return
		end
	end
end

function Animator:add(name, loop, track)
	if self.state then
		self.state:addAnimationByName(track, name, loop)
	end
end

function Animator:set(name, loop, track)
	if self.state then
		self.state:setAnimationByName(track, name, loop)
	end
end

function Animator:update()
	if self.state and self.skeleton then
		self.state:update(tickRate)
		self.state:apply(self.skeleton)
		self.skeleton:updateWorldTransform()
	end
end

function Animator:draw()
	if self.skeleton then
		self.skeleton:draw()
	end
end
