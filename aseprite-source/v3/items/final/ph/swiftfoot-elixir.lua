-- swiftfoot-elixir (lean D2o_17)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local function shade(c, m, ramp, R, tok, bias, o)
  o = o or {} o.tok = tok o.bias = bias
  local n = X.pillow(m, R) local idx, v = G.toneN(c, m, n, ramp, o) return idx, v, n
end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "swiftfoot-elixir" }
local GLASS = { "#5b6f94", "#8aa0bf", "#b4c8d8", "#d4e2e6", "#eaf2ee", "#f8fbf4" }
local ORG = { "#7a2a1e", "#b0401e", "#d9631c", "#f08a22", "#ffb23c", "#ffd878" }
local WING = { "#9a5a3a", "#c47c4a", "#e2a064", "#f2c488", "#fbe0b0", "#fff4d8" }
local CORK = { "#4a3020", "#6e4a2c", "#946a3c", "#b88a52", "#d4a96a", "#ecc98c" }
local BRASS = { "#6a4a1a", "#9a6a22", "#c68f2a", "#e6b83c", "#f6d964", "#fff0a0" }
c:groundShadow(25, 57, 9, 2)
-- wings behind the vial (three feathers, fanning out right)
local px0, py0 = 30, 36
for i, f in ipairs{ { -0.75, 15 }, { -0.15, 17 }, { 0.5, 14 } } do
  local ang, len = f[1], f[2]
  local cx, cy = px0 + cos(ang) * len / 2, py0 + sin(ang) * len / 2
  local m, nn = G.oval(cx, cy, len / 2, 3.1, ang, 1)
  shade(c, m, WING, 3, { r = { name = "wing" .. i } })
  for t = 0, len - 2 do c:px(floor(px0 + cos(ang) * (t + 2)), floor(py0 + sin(ang) * (t + 2)), WING[2]) end
  for t = 3, len - 5, 3 do
    c:px(floor(px0 + cos(ang) * t - sin(ang) * 1.5), floor(py0 + sin(ang) * t + cos(ang) * 1.5), WING[5])
  end
end
-- vial
local glass = c:rect(18, 18, 30, 30):add(c:rrect(18, 26, 30, 56, 6))
shade(c, glass, GLASS, 6, { r = { name = "glass" } })
local liq = glass:copy():shrink(1):cut(c:rect(0, 0, 63, 31))
shade(c, liq, ORG, 5, { r = { name = "elixir" } })
for x = 20, 28 do c:px(x, 32, ORG[6]) end
-- bubbles
for _, b in ipairs{ {23, 40}, {26, 46}, {22, 50}, {25, 36} } do c:px(b[1], b[2], ORG[6]) c:px(b[1] + 1, b[2] + 1, ORG[5]) end
for y = 22, 48 do c:px(19, y, GLASS[6]) end
c:px(20, 34, GLASS[6]) c:px(20, 49, GLASS[5])
-- glass lip and cork
shade(c, c:rrect(16, 17, 32, 20, 1), GLASS, 2, { r = { name = "lip" } })
local cork = c:rrect(18, 9, 30, 18, 2)
shade(c, cork, CORK, 5, { r = { name = "cork" } })
for _, p in ipairs{ {21, 12}, {26, 14}, {23, 16}, {28, 11} } do c:px(p[1], p[2], CORK[1]) end
c:px(20, 10, CORK[6]) c:px(21, 10, CORK[6])
-- brass band where wings attach (quirk: wings are strapped on)
shade(c, c:rect(18, 35, 30, 38), BRASS, 2, { r = { name = "band" } })
c:px(20, 35, "#fff6f2")
G.save(c, "swiftfoot-elixir")
