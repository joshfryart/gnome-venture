-- _aA2_1.lua: private helpers for ico-calendar, ico-candy, ico-carp-streamer, ico-carrot (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ico/")
A.CREAM, A.INK = "#fff4d6", "#2b1c26"

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.tok(name) return { r = { name = name } } end

-- per-pixel light snapped to a ramp (dark..light); returns idx table
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  if o.add then for k, a in pairs(o.add) do if v[k] then v[k] = max(0, min(1, v[k] + a)) end end end
  local cuts = o.cuts
  if not cuts then
    cuts = {}
    for i = 1, #ramp - 1 do cuts[i] = 0.12 + 0.78 * (i - 1) / (#ramp - 2) end
  end
  return X.tone(c, m, v, ramp, { cuts = cuts, bias = o.bias, tok = o.tok })
end

function A.ell(cx, cy, rx, ry)
  local m = HP.mask()
  for y = floor(cy - ry) - 1, floor(cy + ry) + 1 do for x = floor(cx - rx) - 1, floor(cx + rx) + 1 do
    local dx, dy = (x - cx) / (rx + 0.45), (y - cy) / (ry + 0.45)
    if dx * dx + dy * dy <= 1 then m:set(x, y) end
  end end
  return m
end

-- nudge the tone index of an already painted pixel
function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y)
  local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d))
  idx[k] = i
  c:put(x, y, ramp[i], tok)
end

function A.set(c, idx, ramp, x, y, i, tok)
  local k = K(x, y)
  if not idx[k] then return end
  idx[k] = i
  c:put(x, y, ramp[i], tok)
end

function A.map(c, rows, x0, y0, pal, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do
    local ch = row:sub(xx, xx)
    if pal[ch] then c:put(x0 + xx - 1, y0 + yy - 1, pal[ch], tok) end
  end end
end

-- mask from a function f(x,y)->bool over a box
function A.fn(x0, y0, x1, y1, f)
  local m = HP.mask()
  for y = y0, y1 do for x = x0, x1 do if f(x, y) then m:set(x, y) end end end
  return m
end

function A.save(c, name, norecentre)
  if not norecentre then G.recentre(c) end
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A
