-- _aB35_4.lua: private helpers for ph/grand-healing-elixir, grape, grape-seed, grapefruit (final pass, Opus).
-- Read-only use of batch2/_b2g2.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g2.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin, cos, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.tok(name) return { r = { name = name } } end

function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.06, wrap = o.wrap or 0.22 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
end

-- grape-type leaf: 5 pointed lobes fanned around `ang` (direction of the tip lobe), serrated
function A.vine(bx, by, ang, size, o)
  o = o or {}
  local sp = o.sp or 0.82
  local lobes = { { ang, size }, { ang - sp, size * 0.86 }, { ang + sp, size * 0.86 },
    { ang - sp * 1.9, size * 0.6 }, { ang + sp * 1.9, size * 0.6 } }
  return G.palm(bx, by, lobes, { sharp = o.sharp or 2.4, floor = o.floor or 0.34, serr = true, spread = o.spread or 2.1, fold = o.fold or 0.5, hole = o.hole })
end
-- tone a palm leaf + pale midribs per lobe + side veins; returns idx
function A.leafPaint(c, m, n, inf, ramp, o)
  o = o or {}
  local tok = o.tok or A.tok("leaf")
  local idx = A.shade(c, m, n, ramp, { tok = tok, bias = o.bias, amb = 0.12, wrap = 0.26, cuts = { 0.2, 0.38, 0.55, 0.7, 0.86 } })
  m:each(function(x, y) local k = K(x, y) local f = inf[k]
    if o.bias and o.bias[k] then return end
    local off = abs(f.da) * f.r
    if off < 0.55 and f.r > 1.2 and f.r < f.R - 1.3 then c:put(x, y, o.vein or ramp[6], tok) return end
    if o.side ~= false and off > 1.1 and off < f.R * 0.3 and abs((f.r - off * 1.25) % 5 - 2.5) < 0.5 and f.r < f.R - 2 then
      c:put(x, y, f.da < 0 and ramp[5] or ramp[2], tok) end
  end)
  return idx
end

-- shift drawing so the outlined bbox is centred
function A.centre(c)
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for i in pairs(c.pix) do local x, y = i % c.w, i // c.w x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y) end
  x0, y0, x1, y1 = x0 - 1, y0 - 1, x1 + 1, y1 + 1
  local dx, dy = floor((64 - (x1 - x0 + 1)) / 2) - x0, floor((64 - (y1 - y0 + 1)) / 2 + 0.5) - y0
  G.shift(c, dx, dy)
  print(string.format("centre dx %d dy %d size %dx%d", dx, dy, x1 - x0 + 1, y1 - y0 + 1))
end
function A.save(c, name)
  A.centre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
-- paint hand rows: map char -> hex
function A.rows(c, x, y, rows, map, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do local ch = row:sub(xx, xx)
    if map[ch] then c:put(x + xx - 1, y + yy - 1, map[ch], tok) end end end
end
return A
