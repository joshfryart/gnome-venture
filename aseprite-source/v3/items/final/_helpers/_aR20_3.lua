-- _aR20_3.lua: private helpers for ph/black-eyed-susan-seed, black-feather, black-iris-seed, black-pepper (final, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local R = setmetatable({}, { __index = G })
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
R.HP, R.X, R.K = HP, X, K
R.OUT = app.params.out or (DIR .. "/../ph/")
R.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
function R.new(name) R.name = name return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function R.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or R.CUTS, bias = o.bias, tok = o.tok }), v
end
-- 1px bresenham line, optionally clipped to mask
function R.line(c, x0, y0, x1, y1, col, clip, tok)
  x0, y0, x1, y1 = floor(x0 + .5), floor(y0 + .5), floor(x1 + .5), floor(y1 + .5)
  local dx, dy = abs(x1 - x0), -abs(y1 - y0)
  local sx, sy = x0 < x1 and 1 or -1, y0 < y1 and 1 or -1
  local err = dx + dy
  while true do
    if not clip or clip:has(x0, y0) then c:put(x0, y0, col, tok) end
    if x0 == x1 and y0 == y1 then break end
    local e2 = 2 * err
    if e2 >= dy then err = err + dy x0 = x0 + sx end
    if e2 <= dx then err = err + dx y0 = y0 + sy end
  end
end
function R.finish(c)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = R.OUT .. R.name .. ".aseprite", png = R.OUT .. R.name .. ".png", scale = 1 }
end
return R
