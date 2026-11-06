-- _aC32_1.lua: private helpers for ph/parsley-seed, pasque-flower-seed, passion-fruit, passion-fruit-curd (final, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- light + quantise a normal field onto a ramp (dark..light). o: bias, cuts, amb, wrap, tok
function A.tone(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok or { r = { name = o.name or "p" } } }), v
end

-- 1px polyline (hard pixels), returns mask
function A.pline(pts)
  local m = HP.mask()
  for i = 1, #pts - 1 do
    local x0, y0, x1, y1 = pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2]
    local n = max(abs(x1 - x0), abs(y1 - y0))
    for j = 0, n do local t = n == 0 and 0 or j / n
      m:set(floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5)) end
  end
  return m
end

-- ragged tear: remove pixels of m on the far side of a wobbly line through (px,py) with normal (nx,ny)
function A.tear(m, px, py, nx, ny, amp, seed)
  local cut = {}
  m:each(function(x, y)
    local d = (x - px) * nx + (y - py) * ny
    local along = (x - px) * (-ny) + (y - py) * nx
    local w = (X.hash(floor(along), 0, seed or 1) - 0.5) * 2 * amp + (floor(along) % 3 == 0 and amp * 0.6 or 0)
    if d > w then cut[#cut + 1] = K(x, y) end
  end)
  for _, k in ipairs(cut) do m.s[k] = nil end
  return m
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A
