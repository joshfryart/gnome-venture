-- stage-cover-3 (lean E2_08)
local NAME = "stage-cover-3"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.86 }
local function blob(m, ramp, name, R, o)
  o = o or {}
  local n = X.pillow(m, R or 3)
  local tok = { r = { name = name } }
  return X.tone(c, m, X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.22 }), ramp, { cuts = CUTS, tok = tok }), n, tok
end
local function put(x, y, col, name) c:put(floor(x + .5), floor(y + .5), col, { r = { name = name or "d" } }) end
local function dots(m, col, name) m:each(function(x, y) c:put(x, y, col, { r = { name = name or "d" } }) end) end

local SOIL = { "#2a1a14", "#4a2e20", "#6e4630", "#8c6240", "#aa8052", "#c8a470" }
local LEAF = { "#133a2c", "#1c5a38", "#2a7c40", "#44a04c", "#6cc45c", "#a6e07a" }
local STEM = { "#2a5a30", "#3c7c3c", "#58a04c", "#86c468" }
c:groundShadow(32, 57, 26, 3)
local mound = HP.mask()
for y = 36, 56 do for x = 4, 60 do
  local dx, dy = (x - 32) / 27, (y - 47) / 9.5
  if dx * dx + dy * dy <= 1 and not (y < 47 and dx*dx + ((y-47)/11)^2 > 1) then mound:set(x, y) end
end end
local _, mn, mtok = blob(mound, SOIL, "soil", 9, { wrap = 0.25 })
mound:each(function(x, y) local h = X.hash(x, y, 5)
  if h > 0.9 then c:put(x, y, SOIL[6], mtok) elseif h < 0.07 then c:put(x, y, SOIL[1], mtok) end end)
-- a pebble
local peb = c:ellipse(51, 50, 3, 2) blob(peb, { "#4a4850", "#6a6874", "#8a8894", "#aaa8b2", "#c8c6d0", "#e6e4ec" }, "pebble", 2)
local function stem(pts, w) if #pts == 3 then pts = { pts[1], pts[2], pts[2], pts[3] } elseif #pts == 2 then pts = { pts[1], pts[1], pts[2], pts[2] } end local m = G.tube(pts, function(t) return w or 0.9 end) dots(m, STEM[3], "stem") return m end
local function leaflet(cx, cy, rx, ry, name)
  local m = c:ellipse(cx, cy, rx, ry)
  blob(m, LEAF, name, max(rx, ry) + 0.5, { wrap = 0.25 })
  put(cx - 1, cy - 1, LEAF[6], "hi")
  return m
end
local function clover(cx, cy, s, rot, name)
  for k = 0, 2 do
    local a = rot + k * 2.094
    leaflet(cx + cos(a) * s * 0.95, cy + sin(a) * s * 0.95, s * 0.95, s * 0.8, name .. k)
  end
  put(cx, cy, LEAF[1], "ao")
end

local PINK = { "#7a2a54", "#b44a78", "#e0709a", "#f4a0bc", "#fcd0dc", "#fafcff" }
-- dense mat of clover leaves, low at the sides, tall in the back
clover(15, 41, 4.8, 0.3, "m1") clover(49, 42, 4.8, 2.7, "m2")
clover(24, 44, 4.5, 1.0, "m3") clover(41, 45, 4.5, 2.0, "m4")
stem({ {22,44}, {20,34}, {20,28} }) clover(20, 24, 4.6, -1.57, "m5")
stem({ {43,44}, {45,34}, {45,26} }) clover(45, 22, 4.6, -1.57, "m6")
clover(32, 46, 4.2, 1.6, "m7")
-- two pompom flower heads on tall stems
local function flower(x, y, name)
  stem({ {x, 46}, {x + 1, (y + 46) // 2}, {x, y + 3} }, 1.0)
  local fm = c:ellipse(x, y, 5, 5)
  local _, n, tok = blob(fm, PINK, name, 5, { wrap = 0.3 })
  fm:each(function(a, b) if (a + b * 2) % 4 == 0 and X.hash(a, b, 7) > 0.2 then c:put(a, b, PINK[5], tok) elseif (a * 2 + b) % 5 == 0 then c:put(a, b, PINK[2], tok) end end)
  put(x - 2, y - 2, PINK[6], "spec")
  clover(x + 1, y + 7, 2.2, 0.3, name .. "c")
end
flower(32, 14, "fl1")
flower(53, 28, "fl2")
-- quirk: a bee visiting the big bloom
local bee = c:ellipse(40, 10, 2.5, 1.8)
blob(bee, { "#3a2a08", "#6a4a10", "#a87c1c", "#d8a828", "#f4d048", "#fff0a0" }, "bee", 2)
put(39,10,"#2a1a10") put(41,10,"#2a1a10")
put(38,7,"#e8f4ff") put(40,7,"#e8f4ff") put(39,8,"#c4dcf0") put(41,8,"#c4dcf0")
c:sparkle(10, 34)
G.save(c, NAME)
