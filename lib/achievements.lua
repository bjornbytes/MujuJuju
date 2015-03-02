Achievements = class()

function Achievements:init(user)
  self:load(user)

  ctx.event:on('achievement', function(achievement)
    achievement = self.achievements[achievement.name]
    if achievement and not achievement.achieved then
      if achievement:apply() then
        print('You achieved ' .. achievement.title .. '. Congrats, dude.')
        achievement.achieved = true
        self:save(user)
      end
    end
  end)
end

function Achievements:load(user)
  local achievements = json.decode(love.filesystem.read('save/' .. user.name .. '/achievements.json') or '{}')
  for _, name in ipairs(achievements) do
    if self.achievements[name] then
      self.achievements[name].achieved = true
      print(name)
    end
  end
end

function Achievements:save(user)
  local achievements = {}
  for key, value in pairs(Achievements.achievements) do
    if value.achieved then
      table.insert(achievements, key)
    end
  end

  love.filesystem.createDirectory('save')
  love.filesystem.createDirectory('save/' .. user.name)
  love.filesystem.write('save/' .. user.name .. '/achievements.json', json.encode(achievements))
end

Achievements.achievements = {
  miniarsenal = {
    value = 0,
    title = 'Mini Arsenal',
    description = 'Summon 10 minions in a single game.',
    apply = function(self)
      self.value = self.value + 1

      if self.value == 10 then
        return true
      end
    end
  },

  ninelives = {
    value = 0,
    title = 'Nine Lives',
    description = 'Die and be reborn 10 times in a single game.',
    apply = function()
      self.value = self.value + 1

      if self.value == 10 then
        return true
      end
    end
  }
}
