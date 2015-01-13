Spells = extend(Manager)
Spells.manages = 'spell'

function Spells:clear()
  table.each(self.objects, function(spell)
    self:remove(spell)
  end)
  self:init()
end
