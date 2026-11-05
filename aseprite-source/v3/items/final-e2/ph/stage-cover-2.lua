-- stage-cover-2 (lean E2_08)
local NAME = "stage-cover-2"
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

stem({ {18,46}, {17,38}, {16,32} }) clover(16, 28, 4.5, -1.57, "cA")
stem({ {32,46}, {33,36}, {32,24} }) clover(32, 20, 5, -1.57, "cB")
stem({ {47,47}, {47,40}, {49,34} }) clover(49, 30, 4.5, -1.57, "cC")
stem({ {25,47}, {26,44} }) clover(25, 41, 3.6, 0.5, "cD")
stem({ {40,47}, {39,45} }) clover(40, 42, 3.6, 2.6, "cE")
-- quirk: ladybug on the tallest clover
local lb = c:ellipse(37, 18, 2, 1.7)
blob(lb, { "#4a0a12", "#8a1420", "#c42a2a", "#e8483c", "#f87a5a", "#ffc0a0" }, "ladybug", 2)
put(37,17,"#1e0f14") put(36,19,"#1e0f14") put(38,19,"#1e0f14")
c:sparkle(12, 24)
G.save(c, NAME)
