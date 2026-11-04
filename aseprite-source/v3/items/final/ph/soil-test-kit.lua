-- soil-test-kit (lean D2o_2)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "soil-test-kit" }
local function shade(m, ramp, R, bias, cuts) local n = X.pillow(m, R) return G.tone(c, m, X.light(n, { amb = 0.1, wrap = 0.25 }), ramp, cuts, bias) end
-- soil test kit: dropper bottle of green reagent beside a pH colour card; the card's green swatch has a fresh drop-ring (quirk)
local GLASS = { "#2c5a7a", "#3e84a8", "#6cb4cc", "#a0d8e4", "#d0f0f4", "#f0fcff" }
local LIQ   = { "#1e6a3c", "#2c9448", "#4cc060", "#84e07c", "#b8f4a0", "#e4ffcc" }
local RUB   = { "#5a1a1e", "#8a2a2a", "#b84040", "#dc6454", "#f08c70", "#ffc0a0" }
local CARD  = { "#8a7c68", "#b4a68a", "#d8ccb0", "#ece2c8", "#f8f0dc", "#fffaec" }
c:groundShadow(32, 57, 24, 2)
-- card
shade(c:rect(33, 12, 54, 54), CARD, 14, nil, { 0.15, 0.3, 0.45, 0.6, 0.8 })
local SW = { "#c8402e", "#e8802c", "#e8cc3c", "#44b04c", "#6a58b8" }
local SH = { "#8a2420", "#b45a22", "#b49a28", "#2a7c34", "#46388a" }
for i = 0, 4 do
  local y0 = 16 + i * 7
  c:fillMask(c:rect(36, y0, 51, y0 + 5), SW[i + 1])
  c:fillMask(c:rect(36, y0 + 5, 51, y0 + 5), SH[i + 1])
  c:fillMask(c:rect(51, y0, 51, y0 + 5), SH[i + 1])
  c:px(36, y0, "#ffffd8") c:px(37, y0, "#ffffd8")
end
c:fillMask(c:line({ {40, 36}, {44, 36}, {45, 37}, {44, 39}, {40, 39}, {39, 37}, {40, 36} }, 1), "#1c5c28")
c:px(42, 37, "#9cf090")
-- bottle
local bot = c:rrect(9, 32, 28, 55, 3)
bot:add(c:rect(15, 25, 22, 32))
shade(bot, GLASS, 8)
local liq = c:rrect(11, 40, 26, 54, 2) shade(liq, LIQ, 7)
c:fillMask(c:rect(11, 40, 26, 40), LIQ[5])
for y = 34, 52 do c:px(11, y, GLASS[6]) end
c:px(12, 33, GLASS[6])
-- label
c:fillMask(c:rect(13, 44, 24, 49), CARD[4]) c:fillMask(c:rect(13, 49, 24, 49), CARD[2])
c:fillMask(c:rect(15, 46, 22, 46), "#6a5a44") c:fillMask(c:rect(15, 48, 20, 48), "#6a5a44")
-- collar + dropper bulb
shade(c:rect(14, 22, 23, 25), RUB, 2)
shade(c:ellipse(18.5, 15, 4.5, 7), RUB, 5)
c:px(16, 11, RUB[6]) c:px(16, 12, RUB[5])
G.fin(c, "soil-test-kit")
