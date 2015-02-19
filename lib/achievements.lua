Achievements = class()

function Achievements:init()
  ctx.event:on('achievement', function(achievement)
    achievement = self.achievements[achievement.name]
    if achievement and not achievement.achieved then
      if achievement:apply() then
        print('You achieved ' .. achievement.title .. '. Congrats, dude.')
        achievement.achieved = true
      end
    end
  end)
end

Achievements.achievements = {
  miniarsenal = {
    value = 0,
    title = 'Mini Arsenal',
    description = 'Summon 10 minions in a single game.',
    apply = function(self)
      self.value = self.value + 1
      print('Summoned ' .. self.value .. '.')

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
