-- stuffed-peppers-goat (lean D2o_16)
local NAME = "stuffed-peppers-goat"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local function blob(m, ramp, R, o, cuts, bias)
  local n = X.pillow(m, R)
  local v = X.light(n, o or { amb = 0.1, wrap = 0.25 })
  G.tone(c, m, v, ramp, cuts, bias)
  return v, n
end
local function lines(pts, hex) G.line(c, pts, hex) end
local function hits(m, fn) m:each(fn) end

-- stuffed half red pepper on a plate, goat-cheese dollop with chive sprig; quirk: cheese drip down the front
local PLATE = { "#6e5a6a", "#9a8590", "#c4b3b0", "#e4d8cf", "#f6eee2", "#fffaf0" }
local RED = { "#4a1424", "#7a1a2c", "#a82434", "#d03a3c", "#ec6048", "#ff9a78" }
local CHE = { "#8f8ba6", "#b9b4c6", "#dcd7df", "#f0ece8", "#faf6ee", "#fffaf0" }
local GR = { "#1f3d34", "#2c5a3a", "#3f7a42", "#5c9a4c", "#88bc60", "#b6d886" }
local plate = c:ellipse(32, 50, 26, 9)
blob(plate, PLATE, 5, { amb = 0.15, wrap = 0.3 })
local well = c:ellipse(32, 50, 19, 6)
G.tone(c, well, X.light(X.pillow(well, 4), { amb = 0.05, wrap = 0.2 }), PLATE, { 0.5, 0.7, 0.85, 0.95, 1.1 })
c:fillMask(c:ellipse(33, 54, 12, 2):cut(c:ellipse(32, 51, 18, 4)), PLATE[1])
local body = c:ellipse(32, 38, 14, 13):cut(c:rect(0, 0, 63, 28))
blob(body, RED, 9, { amb = 0.08, wrap = 0.2 })
for _, x in ipairs{ 25, 39 } do lines({ { x, 33 }, { x - 1, 40 }, { x + 1, 47 } }, RED[2]) end
lines({ { 27, 33 }, { 26, 38 } }, RED[5])
local rim = c:ellipse(32, 29, 14, 4.5)
blob(rim, RED, 3, { amb = 0.3, wrap = 0.3 })
local hole = c:ellipse(32, 29.5, 11, 3)
c:fillMask(hole, CHE[1])
local dol = c:ellipse(32, 26, 8, 5):add(c:ellipse(29, 24, 4, 3))
blob(dol, CHE, 4, { amb = 0.15, wrap = 0.25 })
-- cheese drip over the rim
c:fillMask(c:rect(35, 30, 36, 33), CHE[3]) c:px(35, 34, CHE[3]) c:px(36, 32, CHE[2]) c:px(36, 33, CHE[2])
-- chive sprig + leaf
lines({ { 33, 22 }, { 36, 19 }, { 40, 17 } }, GR[4]) lines({ { 32, 22 }, { 31, 17 }, { 33, 14 } }, GR[3])
local lf = G.rell(38, 20, 0.8, -0.6, 4, 1.8)
blob(lf, GR, 1.5)
lines({ { 35, 22 }, { 40, 18 } }, GR[6])
-- crumbs and spec
c:px(22, 49, CHE[4]) c:px(43, 51, CHE[3]) c:px(26, 35, RED[6]) c:px(27, 34, RED[6]) c:px(26, 36, RED[5])
c:px(29, 23, CHE[6])

G.fin(c, NAME)
