-- sundial (lean D2o_16)
local NAME = "sundial"
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

-- sundial: round stone dial plate on a fluted pedestal, brass gnomon casting a shadow over hour ticks; quirk: tiny snail on the rim
local ST = { "#3a3846", "#5a5668", "#7d7889", "#a29da8", "#c6c0c4", "#e6e0dc" }
local BR = { "#4a2e1a", "#7a4c20", "#a8782c", "#d4a444", "#f0cc68", "#fff0a0" }
local MOSS = { "#2c4a2a", "#4a7a3a", "#78a850" }
c:groundShadow(32, 55, 18, 2)
local flare = c:ellipse(32, 53, 15, 4)
blob(flare, ST, 3, { amb = 0.15, wrap = 0.25 })
local col = c:rect(26, 42, 38, 52)
local nn = X.pillow(col, 6)
blob(col, ST, 6, { amb = 0.1, wrap = 0.2 })
for _, x in ipairs{ 29, 32, 35 } do lines({ { x, 46 }, { x, 54 } }, ST[2]) end
lines({ { 28, 46 }, { 28, 53 } }, ST[5])
local under = c:ellipse(32, 43, 25, 9)
blob(under, ST, 5, { amb = 0.02, wrap = 0.1 })
local plate = c:ellipse(32, 38, 25, 10)
blob(plate, ST, 6, { amb = 0.25, wrap = 0.3 })
local ring = c:ellipse(32, 38, 21, 8):cut(c:ellipse(32, 38, 19, 7))
c:fillMask(ring, ST[2])
local face = c:ellipse(32, 38, 19, 7)
c:fillMask(face, ST[5])
c:fillMask(c:ellipse(32, 37, 15, 5), ST[6])
-- hour ticks around the dial
for i = 0, 11 do
  local a = i * pi / 6
  local x0, y0 = 32 + cos(a) * 14.5, 38 + sin(a) * 5.3
  local x1, y1 = 32 + cos(a) * 18, 38 + sin(a) * 6.6
  lines({ { floor(x0 + 0.5), floor(y0 + 0.5) }, { floor(x1 + 0.5), floor(y1 + 0.5) } }, ST[1])
end
-- shadow (light upper-left, falls lower-right)
c:fillMask(c:poly{ { 32, 37 }, { 46, 38 }, { 47, 40 }, { 33, 39 } }, ST[3])
c:fillMask(c:poly{ { 32, 37 }, { 40, 38 }, { 41, 39 }, { 33, 38 } }, ST[2])
-- brass gnomon: right triangle standing on the centre
local g = c:poly{ { 29, 39 }, { 29, 23 }, { 31, 22 }, { 40, 38 }, { 38, 40 } }
blob(g, BR, 4, { amb = 0.25, wrap = 0.35 })
lines({ { 30, 25 }, { 30, 37 } }, BR[6])
lines({ { 32, 25 }, { 38, 37 } }, BR[2])
c:px(30, 23, BR[6])
-- moss on the rim and a snail (quirk)
for _, p in ipairs{ { 10, 40 }, { 11, 41 }, { 12, 42 }, { 11, 40 } } do c:px(p[1], p[2], MOSS[2]) end
c:px(10, 41, MOSS[3]) c:px(12, 43, MOSS[1])
c:fillMask(c:ellipse(51, 36, 1.5, 1.5), "#c88a58") c:px(51, 36, "#8a5a3a") c:px(53, 37, "#e8c8a0") c:px(52, 37, "#e8c8a0")

G.fin(c, NAME)
