-- _aB10_5.lua: private helpers for ph/broccoli, broccoli-seed, broken-bug-net, broken-cane-fishing-rod (final, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local floor, max, min = math.floor, math.max, math.min
A.HP, A.X, A.K = HP, X, K
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
-- light a normal field and paint it with a ramp; returns idx, tok
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok or { r = { name = o.name or "part" } } })
end
-- re-tone one pixel by d steps
function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end
-- hand-placed pixel map, cols = {char = hex}
function A.map(c, x0, y0, rows, cols, tok)
  for j, row in ipairs(rows) do for i = 1, #row do local ch = row:sub(i, i)
    if cols[ch] then c:put(x0 + i - 1, y0 + j - 1, cols[ch], tok) end end end
end
A.hash = X.hash
function A.save(c, name) G.save2(c, name) end
return A
