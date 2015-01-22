require 'love.filesystem'

local sha1 = require 'lib/deps/sha1/sha1'
local http = require 'socket.http'
local json = require 'lib/deps/dkjson'

local protocol = 'http'
local address = '96.126.101.55'
local port = 7000

local hash, hashes = ...

local response = love.thread.getChannel('patcher.response')

local function format(data)
  if not data then return '' end
  local t = {}
  for k, v in pairs(data) do t[#t + 1] = k .. '=' .. v end
  return table.concat(t, '&')
end

local str, code = http.request(protocol .. '://' .. address .. ':' .. port .. '/api/patch', format({hash = hash}))
local json = json.decode(str)

if code == 200 and json.patch then 
  local str, code = http.request(protocol .. '://' .. address .. ':' .. port .. '/api/patch', format({hashes = hashes}))
  love.filesystem.write('patch.zip', str)
end

response:push(type(json) == 'table' and type(json.patch) == 'bool' and json.patch == true)
