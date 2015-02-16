require 'love.filesystem'
require 'love.timer'
local sha1 = require 'lib/deps/sha1/sha1'

local out = love.thread.getChannel('hasher.out')

local sleep = .001
local hashes = {}
local ignore = {'.git', '.DS_Store', 'error.log', '.swp', '.swo', 'playedBefore', 'user.json', 'patch.zip'}

local function halp(base)
  for _, file in ipairs(love.filesystem.getDirectoryItems(base)) do
    local path = base .. '/' .. file
    local ignored = false

    for _, name in pairs(ignore) do
      if path:find(name) then ignored = true end
    end

    if not ignored then
      if love.filesystem.isDirectory(path) then
        halp(path)
      else
        local entry = {path = path, hash = sha1(love.filesystem.read(path))}
        table.insert(hashes, entry)
        out:push(entry)
      end
    end

    love.timer.sleep(sleep)
  end
end

halp('')

table.sort(hashes, function(a, b) return a.path < b.path end)
for key, entry in pairs(hashes) do
  hashes[key] = entry.hash
end

local gameHash = sha1(table.concat(hashes, ''))

out:push('done')
out:push(gameHash)
