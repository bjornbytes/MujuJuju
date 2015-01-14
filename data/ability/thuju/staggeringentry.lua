local StaggeringEntry = class()

function StaggeringEntry:spawn()
  for i = 1, #self.unit.abilities do
    local ability = self.unit.abilities[i]
    if ability.code == 'tremor' or ability.code == 'inspire' then
      ability:fire()
      ability.timer = 0
    end
  end
end

return StaggeringEntry
