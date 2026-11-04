-- _aB1r0_4.lua: private helpers for ph/carob, carob-seed, carrot-cake, carved-heron (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local floor, max, min, sqrt = math.floor, math.max, math.min, math.sqrt
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.tok(name) return { r = { name = name } } end
function A.norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end

-- light a normal field and tone it; returns idx
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.06, wrap = o.wrap or 0.22 })
  return (X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok }))
end

-- blend pillow + sphere normals: rounded body with soft edges
function A.body(m, cx, cy, r, R, wS)
  local np = X.pillow(m, R or 4)
  local ns = X.sphere(cx, cy, r, m)
  local n, w = {}, wS or 0.55
  for k, a in pairs(np) do local b = ns[k] or a
    n[k] = { A.norm(a[1] * (1 - w) + b[1] * w, a[2] * (1 - w) + b[2] * w, a[3] * (1 - w) + b[3] * w) } end
  return n
end

-- polygon mask (even-odd, pixel centres)
function A.poly(pts)
  local m = HP.mask()
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for _, p in ipairs(pts) do x0, y0, x1, y1 = min(x0, p[1]), min(y0, p[2]), max(x1, p[1]), max(y1, p[2]) end
  for y = floor(y0), floor(y1) + 1 do for x = floor(x0), floor(x1) + 1 do
    local inside, j = false, #pts
    for i = 1, #pts do
      local xi, yi, xj, yj = pts[i][1], pts[i][2], pts[j][1], pts[j][2]
      if ((yi > y) ~= (yj > y)) and (x < (xj - xi) * (y - yi) / (yj - yi) + xi) then inside = not inside end
      j = i
    end
    if inside then m:set(x, y) end
  end end
  return m
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  local r = HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
  return r
end
return A
