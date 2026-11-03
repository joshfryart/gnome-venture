-- _aA10_2: helper for ico-star, ico-star-empty, ico-stone-wall, ico-storm (Opus artist pass). Read-only use of batch2/_b2g1.lua.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, max, min, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi
local D = { G = G, HP = HP, X = X, K = K, INK = "#2b1c26", CREAM = "#fff4d6" }
-- 6-tone ramps, dark -> light
D.GOLD  = { "#7a2f22", "#b4521e", "#e07f1c", "#f7ae26", "#ffd44e", "#fff09a" }
D.PEW   = { "#383a58", "#545670", "#74758c", "#9799ae", "#bfc0d0", "#e6e7f0" }
D.SOCK  = { "#1f1830", "#2d2446", "#3e335e", "#524675", "#6a5e8e" }
D.STC   = { "#3a3c58", "#56586f", "#787a8e", "#9c9dae", "#c2c3ce", "#e4e4ea" } -- cool stone
D.STW   = { "#463a4a", "#665662", "#8a7a7e", "#ab9c96", "#cbbfb2", "#e8e0d2" } -- warm stone
D.STS   = { "#4e3a3a", "#76584a", "#9c7c5c", "#bfa074", "#dcc290", "#f2e2b4" } -- sandy stone
D.MOSS  = { "#1c4638", "#2b6440", "#3f8a48", "#62ad52", "#98cf68", "#c8e88a" }
D.CLOUD = { "#241e3c", "#363058", "#4c4676", "#686496", "#8e8cb6", "#bcbcd8" }
D.RAIN  = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" }
D.SNAIL = { "#4a2a4a", "#7a3e6a", "#b05a8a", "#e08aa8", "#ffc4d8" }
D.BODY  = { "#6a5a4a", "#a08c6a", "#cdb98a", "#ecdcac" }
D.LEAF  = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }

function D.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function D.tone(c, m, n, ramp, o) return G.toneN(c, m, n, ramp, o) end
function D.find(ramp, hex) for i, h in ipairs(ramp) do if h:lower() == (hex or ""):lower() then return i end end end
function D.shift(c, x, y, ramp, d)
  local i = D.find(ramp, c:get(x, y)) if i then c:put(x, y, ramp[max(1, min(#ramp, i + d))], c.own[y * c.w + x]) end
end
function D.set(c, x, y, hex, tok) c:put(x, y, hex, tok or c.own[y * c.w + x]) end
-- float polygon -> mask (pixel centres)
function D.poly(pts)
  local m = HP.mask()
  local y0, y1 = 1e9, -1e9
  for _, p in ipairs(pts) do y0 = min(y0, p[2]) y1 = max(y1, p[2]) end
  for y = floor(y0) - 1, floor(y1) + 1 do
    local xs = {}
    for i = 1, #pts do
      local a, b = pts[i], pts[i % #pts + 1]
      if (a[2] <= y) ~= (b[2] <= y) then xs[#xs + 1] = a[1] + (y - a[2]) / (b[2] - a[2]) * (b[1] - a[1]) end
    end
    table.sort(xs)
    for i = 1, #xs - 1, 2 do
      for x = math.ceil(xs[i] - 0.5), floor(xs[i + 1] - 0.5) do m:set(x, y) end
    end
  end
  return m
end
function D.starPts(cx, cy, ro, ri, n, rot)
  local p = {}
  for i = 0, 2 * n - 1 do
    local r = (i % 2 == 0) and ro or ri
    local a = (rot or -pi / 2) + i * pi / n
    p[#p + 1] = { cx + cos(a) * r, cy + sin(a) * r }
  end
  return p
end
-- rounded-tip star: polygon + small discs at the tips, minus nothing
function D.star(cx, cy, ro, ri, rot, tipR)
  local pts = D.starPts(cx, cy, ro, ri, 5, rot)
  local m = D.poly(pts)
  return m, pts
end
function D.ell(cx, cy, rx, ry)
  local m = HP.mask()
  for y = floor(cy - ry) - 1, floor(cy + ry) + 1 do for x = floor(cx - rx) - 1, floor(cx + rx) + 1 do
    if ((x - cx) / rx) ^ 2 + ((y - cy) / ry) ^ 2 <= 1 then m:set(x, y) end end end
  return m
end
function D.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  local out = app.params.out or (DIR .. "/../ico/")
  c:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
return D
