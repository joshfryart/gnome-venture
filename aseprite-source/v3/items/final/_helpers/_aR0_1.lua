-- _aR0_1.lua: private helpers for ico/ico-tea, ico-telescope, ico-tent, ico-test-tube (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local R = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
R.HP, R.X, R.K = HP, X, K
R.OUT = app.params.out or (DIR .. "/../ico/")
R.INK, R.CREAM = "#2b1c26", "#fff4d6"
R.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
R.norm = norm

function R.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- light a normal field into a ramp (dark..light); returns idx, v, tok
function R.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local tok = o.tok or { r = { name = o.name or tostring(ramp) } }
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or R.CUTS, bias = o.bias, tok = tok })
  return idx, v, tok
end
-- re-tone one already-painted pixel by d steps
function R.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end
-- 1px line, Bresenham-ish
function R.ln(c, x0, y0, x1, y1, hex, tok)
  local n = max(abs(x1 - x0), abs(y1 - y0), 1)
  for s = 0, n do c:put(floor(x0 + (x1 - x0) * s / n + .5), floor(y0 + (y1 - y0) * s / n + .5), hex, tok) end
end
-- pixels of m that 4-touch mask o (used for ambient / inner lines)
function R.touch(m, o)
  local r = HP.mask()
  m:each(function(x, y)
    if o:has(x+1,y) or o:has(x-1,y) or o:has(x,y+1) or o:has(x,y-1) then r:set(x, y) end end)
  return r
end
function R.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = R.OUT .. name .. ".aseprite", png = R.OUT .. name .. ".png", scale = 1 }
end
return R
