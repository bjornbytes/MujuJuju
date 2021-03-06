data = {}
data.load = function()

  -- Media
	local function lookup(ext, fn)
		local function halp(s, k)
			local base = s._path .. '/' .. k
      local function extLoad(ext)
        if love.filesystem.exists(base .. ext) then
          s[k] = fn(base .. ext)
        elseif love.filesystem.isDirectory(base) then
          local t = {}
          t._path = base
          setmetatable(t, {__index = halp})
          s[k] = t
        else
          return false
        end

        return true
      end

      if type(ext) == 'table' then
        table.each(ext, function(e) return extLoad(e) end)
      else
        extLoad(ext)
      end

			return rawget(s, k)
		end

		return halp
	end

  data.media = {}
	data.media.graphics = setmetatable({_path = 'media/graphics'}, {__index = lookup({'.png', '.dds'}, love.graphics and love.graphics.newImage or f.empty)})
	data.media.shaders = setmetatable({_path = 'media/shaders'}, {__index = lookup('.shader', love.graphics and love.graphics.newShader or f.empty)})
	data.media.sounds = setmetatable({_path = 'media/sounds'}, {__index = lookup('.ogg', love.audio and love.audio.newSource or f.empty)})

  -- Data
  local function load(dir, type, fn)
    local id = 1
    local function halp(dir, dst)
      for _, file in ipairs(love.filesystem.getDirectoryItems(dir)) do
        path = dir .. '/' .. file
        if love.filesystem.isDirectory(path) then
          dst[file] = {}
          halp(path, dst[file])
        elseif file:match('%.lua$') and not file:match('^%.') then
          local obj = love.filesystem.load(path)()
          assert(obj, path .. ' did not return a value')
          obj.code = obj.code or file:gsub('%.lua', '')
          obj.id = id
          obj = f.exe(fn, obj) or obj
          data[type][id] = obj
          dst[obj.code] = obj
          id = id + 1
        end
      end
    end

    data[type] = {}
    halp(dir, data[type])
  end

  load('data/buff', 'buff')
  load('data/ability', 'ability', function(ability)
    if ability.upgrades then
      table.each(ability.upgrades, function(upgrade)
        if upgrade.code then
          ability.upgrades[upgrade.code] = upgrade
        end
      end)
    end
  end)
  load('data/unit', 'unit', function(unit)
    if data.media.sounds[unit.code] and data.media.sounds[unit.code]['attackHit1'] then
      local sounds = {}
      for i = 1, 100 do
        if data.media.sounds[unit.code]['attackHit' .. i] then
          table.insert(sounds, 'media/sounds/' .. unit.code .. '/attackHit' .. i .. '.ogg')
        else
          break
        end
      end
      data.media.sounds[unit.code].attackHit = love.audio.newSource(sounds)
    end

    table.each(table.keys(unit.upgrades), function(upgrade, i)
      unit.upgrades[i] = unit.upgrades[upgrade]
      unit.upgrades[i].code = upgrade
    end)

    unit.attributes = {}
    unit.attributeCosts = {}
    table.each(config.attributes.list, function(attribute)
      unit.attributes[attribute] = 0
      unit.attributeCosts[attribute] = config.attributes.baseCost
    end)
  end)
  load('data/spell', 'spell')
  load('data/animation', 'animation', function(animation)

    -- Set up lazy loading for images
    local code = animation.code
    animation.graphics = setmetatable({_path = 'media/skeletons/' .. code}, {
      __index = lookup({'.png', '.dds'}, function(path)
        local img = love.graphics.newImage(path)
        if path:match('%.dds') then img:setMipmapFilter('nearest', 1) end
        return img
      end)
    })

    -- Set up static spine data structures
    local s = {}
    s.__index = s
    if love.filesystem.exists('media/skeletons/' .. code .. '/' .. code .. '.atlas') then
      s.atlas = spine.Atlas.new('media/skeletons/' .. code .. '/' .. code .. '.atlas')
      s.atlasAttachmentLoader = spine.AtlasAttachmentLoader.new(s.atlas)
    end
    s.json = spine.SkeletonJson.new(s.atlasAttachmentLoader)
    s.skeletonData = s.json:readSkeletonDataFile('media/skeletons/' .. code .. '/' .. code .. '.json')
    s.animationStateData = spine.AnimationStateData.new(s.skeletonData)

    -- Reverse-index keys (sorted for consistent order)
    local keys = table.keys(animation.states)
    table.sort(keys)

    for i = 1, #keys do
      local state = animation.states[keys[i]]
      animation.states[i] = state
      state.index = i
      state.name = keys[i]
    end

    -- Set mixes
    for i = 1, #animation.states do
      table.each(animation.states, function(state)
        if state.index ~= i then
          s.animationStateData:setMix(animation.states[i].name, state.name, Animation.defaultMix)
        end
      end)

      table.each(animation.states[i].mix, function(time, to)
        s.animationStateData:setMix(animation.states[i].name, to, time)
      end)
    end

    animation.spine = s

    -- If it's an animation for a unit, make sure all required animations are supplied.
    --[[if data.unit[animation.code] then
      local instance = animation()

      local function check(name)
        local code = animation.code:capitalize()
        local article = 'a'
        local first = name:sub(1, 1)
        if table.has({'a', 'e', 'i', 'o', 'u'}, first) then article = 'an' end

        if not instance.spine.skeletonData:findAnimation(name) then print(code .. ' is missing ' .. article .. ' ' .. name .. ' animation') end
      end

      check('spawn')
      check('idle')
      check('walk')
      check('attack')
      check('death')
    end]]

    return animation
  end)
  load('data/particle', 'particle')
  load('data/effect', 'effect')
  load('data/gooey', 'gooey')
  load('data/shruju', 'shruju')
  load('data/ai', 'ai')
  load('data/atlas', 'atlas')
end

