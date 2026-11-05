-- sorrel (lean E2_07)
local NAME = "sorrel"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function shade(c, m, ramp, R, name, amb, wrap)
  local n = X.pillow(m, R)
  local tok = { r = { name = name } }
  X.tone(c, m, X.light(n, { amb = amb or 0.08, wrap = wrap or 0.25 }), ramp, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.87 }, tok = tok })
  return n, tok
end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
-- quirk: one leaf has a bright red-purple midrib and a tiny dewdrop on its notch
c:groundShadow(30, 58, 16, 2)
local LEAF = { "#1f4a2a", "#2f6a34", "#478c3c", "#66ac48", "#8cc85a", "#bce47c" }
local function rot(px, py, ox, oy, a) return { ox + px * cos(a) - py * sin(a), oy + px * sin(a) + py * cos(a) } end
-- arrowhead (hastate) leaf pointing up in local coords then rotated about base
local function arrow(ox, oy, a, L, W, name)
  local loc = { {0,0}, {W*0.9,0.18*L}, {W*0.5,0.3*L}, {W*0.62,0.2*L}, {W*0.5,0.32*L}, {W*0.25,0.65*L}, {0,L}, {-W*0.25,0.65*L}, {-W*0.5,0.32*L}, {-W*0.62,0.2*L}, {-W*0.5,0.3*L}, {-W*0.9,0.18*L} }
  loc = { {0,0.02*L}, {W*0.8,-0.06*L}, {W*0.5,0.2*L}, {W*0.8,0.36*L}, {W*0.5,0.7*L}, {0,L}, {-W*0.5,0.7*L}, {-W*0.8,0.36*L}, {-W*0.5,0.2*L}, {-W*0.8,-0.06*L} }
  local pts = {}
  for i, p in ipairs(loc) do pts[i] = rot(p[1], -p[2], ox, oy, a) end
  local m = c:poly(pts)
  local n, tok = shade(c, m, LEAF, 5, name, 0.1, 0.28)
  -- midrib along axis
  local tip = rot(0, -L * 0.92, ox, oy, a)
  c:line({ {floor(ox + 0.5), floor(oy + 0.5)}, {floor(tip[1] + 0.5), floor(tip[2] + 0.5)} }, 1):each(function(x, y) if m:has(x, y) then c:put(x, y, "#b8456a", tok) end end)
  return m, tok
end
-- stem with seed whorls
local stm, stn, ST = G.tube({ {30,58}, {29,42}, {34,24}, {38,6} }, function(t) return 1.5 - 0.5 * t end)
local stok = { r = { name = "stem" } }
local sv = X.light(stn, { amb = 0.12, wrap = 0.3 })
X.tone(c, stm, sv, { "#4a1c2c", "#7a2a3a", "#a43c48", "#c4584e", "#8aa448", "#b4c868" }, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.87 }, tok = stok })
-- big leaves
arrow(30, 56, -0.7, 30, 9, "lA")
arrow(30, 56, 0.75, 27, 9, "lB")
arrow(30, 56, -0.05, 18, 6, "lC")
-- re-draw stem over leaf C base is fine; rust seed clusters (tiny winged triangles) up the spike
local RUST = { "#5a1c1c", "#8c2c24", "#b8442c", "#d86a3c", "#ee9456" }
for i, p in ipairs{ {38,8},{36,12},{39,15},{35,19},{37,23},{34,27} } do
  local m = c:ellipse(p[1] + (i % 2 == 0 and 2 or -2), p[2], 2, 1.6)
  shade(c, m, RUST, 1.8, "seed" .. i, 0.1, 0.25)
end
c:put(35, 36, "#eaf8ff") c:put(35, 37, "#9cd4f0") -- dewdrop
c:sparkle(14, 16)
G.save(c, NAME)
