-- _aB10_4.lua: private helpers for bright-feather, broadfork, broccoflower, broccoflower-seed (Opus single pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt

-- paint ramp index per pixel from a table idx[k] (clamped)
function G.putIdx(c, idx, ramp, tok)
  for k, i in pairs(idx) do
    local x, y = k % 1024 - 256, k // 1024 - 256
    c:put(x, y, ramp[max(1, min(#ramp, i))], tok)
  end
end
-- blend two light fields: v = a*va + (1-a)*vb
function G.blend(va, vb, a)
  local v = {}
  for k, x in pairs(va) do v[k] = a * x + (1 - a) * (vb[k] or x) end
  return v
end
-- simple quantise of light value to an index
function G.q(val, cuts)
  local i = 1
  for j, t in ipairs(cuts) do if val >= t then i = j + 1 end end
  return i
end
G.CUTS = { 0.22, 0.4, 0.56, 0.72, 0.87 }
return G
