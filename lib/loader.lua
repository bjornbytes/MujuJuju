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

  local function loadSound(path)
    return love.audio.newSource(path, love.filesystem.getSize(path) > 1e5 and 'stream' or 'static')
  end

  data.media = {}
	data.media.graphics = setmetatable({_path = 'media/graphics'}, {__index = lookup({'.png', '.dds'}, love.graphics and love.graphics.newImage or f.empty)})
	data.media.shaders = setmetatable({_path = 'media/shaders'}, {__index = lookup('.shader', love.graphics and love.graphics.newShader or f.empty)})
	data.media.sounds = setmetatable({_path = 'media/sounds'}, {__index = lookup('.ogg', love.audio and loadSound or f.empty)})

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
  end)
  load('data/spell', 'spell')
  load('data/animation', 'animation', function(animation)
    local keys = table.keys(animation.states)
    table.sort(keys)

    for i = 1, #keys do
      local state = animation.states[keys[i]]
      animation.states[i] = state
      state.index = i
      state.name = keys[i]
    end

    -- If it's an animation for a unit, make sure all required animations are supplied.
    if data.unit[animation.code] then
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
    end

    return animation
  end)
  load('data/particle', 'particle')
  load('data/effect', 'effect')
  load('data/gooey', 'gooey')
  load('data/shruju', 'shruju')
end

