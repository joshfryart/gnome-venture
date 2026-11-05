-- feast-spicepeak-thali (lean P1b_O1)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan

local NAME = "feast-spicepeak-thali"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local STEEL = { "#3b4064", "#5d6a96", "#8d9cc4", "#bccae2", "#e4edf7", "#fffaf0" }
local RICE = { "#9a8aa8", "#c8bccb", "#e8dfe4", "#f9f2ea", "#fffaf0", "#fffaf0" }
local CHILI = { "#5c0f1c", "#9a1626", "#d32a2c", "#f2503a", "#ff8a5a", "#ffc79a" }
local CURRY = { "#8a2c0e", "#c4501a", "#ec7a22", "#ffa23a", "#ffc866", "#ffe6a0" }
local SAAG = { "#1d4a2c", "#2c6e34", "#43953c", "#6bb84a", "#9ad866", "#cdf09a" }
local DAL = { "#a8700e", "#d29a1c", "#f2c42e", "#ffe04e", "#fff08a", "#fffbd0" }
c:groundShadow(32, 55, 25, 3)
-- plate
local pl = c:ellipse(32, 38, 26, 15)
local plate = c:ellipse(32, 41, 26, 14):add(pl)
local pv = {}
plate:each(function(x, y) pv[K(x, y)] = 0.85 - 0.6 * ((x - 6) / 52) - (y > 46 and 0.15 or 0) end)
X.tone(c, plate, pv, STEEL, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 } })
local well = c:ellipse(32, 38, 22, 12)
G.toneN(c, well, X.pillow(well, 12), STEEL, { amb = 0.35, wrap = 0.5, cuts = { 0.2, 0.4, 0.62, 0.8, 0.92 } })
local ring = pl:copy():cut(c:ellipse(32, 38, 23.5, 13))
ring:each(function(x, y) if y < 38 then c:px(x, y, STEEL[5]) end end)
-- katoris
local function bowl(cx, cy, rx, ry, ramp)
  local o = c:ellipse(cx, cy, rx, ry)
  local ob = c:ellipse(cx, cy + 2, rx, ry):add(o)
  G.toneN(c, ob, X.pillow(ob, 4), STEEL, {})
  local i = c:ellipse(cx, cy, rx - 1.5, ry - 1)
  G.toneN(c, i, X.pillow(i, 3), ramp, { amb = 0.15 })
  return i
end
local i1 = bowl(15, 40, 6.5, 4, CURRY)
local i2 = bowl(49, 40, 6.5, 4, SAAG)
local i3 = bowl(32, 50, 7, 4, DAL)
i1:each(function(x, y) if X.hash(x, y, 2) > 0.9 then c:px(x, y, CURRY[6]) end end)
c:px(13, 38, CURRY[6]) c:px(14, 38, CURRY[6])
c:px(47, 38, SAAG[6]) c:px(51, 41, SAAG[1])
c:px(30, 48, DAL[6]) c:px(31, 48, DAL[6])
-- rice cone
local cone = HP.mask()
for y = 14, 43 do local t = (y - 14) / 29
  local h = 0.4 + 14 * t ^ 0.85
  if y > 40 then h = h - (y - 40) * 1.2 end
  for x = floor(32 - h + 0.5), floor(32 + h - 0.5) do cone:set(x, y) end end
local cv = {}
cone:each(function(x, y) local h = 0.4 + 14 * ((y - 14) / 29) ^ 0.85
  local f = 0.92 - 0.75 * ((x - (32 - h)) / (2 * h + 0.01)) ^ 0.9
  if y > 38 then f = f - 0.12 * (y - 38) / 4 end
  cv[K(x, y)] = max(0, min(1, f)) end)
local idx = X.tone(c, cone, cv, RICE, { cuts = { 0.16, 0.34, 0.5, 0.66, 0.82 } })
cone:each(function(x, y) local h = X.hash(x, y, 8)
  if h > 0.86 then c:px(x, y, RICE[(h > 0.95) and 6 or 2]) end
  if X.hash(x, y, 9) > 0.965 then c:px(x, y, "#f2b42a") end end)
-- chili spire (quirk: red peak with green stem)
local chm, chn = G.tube({ {33, 20}, {31, 15}, {32, 11}, {30, 7} }, function(t) return 2.4 * (1 - t) + 0.3 end)
G.toneN(c, chm, chn, CHILI, { amb = 0.1 })
c:px(32, 14, CHILI[6]) c:px(32, 16, CHILI[5]) c:px(33, 18, CHILI[1])
c:fillMask(c:rect(34, 20, 36, 20), SAAG[3]) c:px(37, 19, SAAG[2]) c:px(35, 21, SAAG[1])
-- chili flakes on cone
for _, p in ipairs{ {28,26},{36,30},{31,33},{25,38},{38,36},{33,24},{29,31} } do c:px(p[1], p[2], CHILI[3]) c:px(p[1] + 1, p[2], CHILI[4]) end
-- steam
c:px(26, 9, "#f6f2ff") c:px(27, 8, "#dcd6f0") c:px(26, 7, "#f6f2ff") c:px(25, 6, "#dcd6f0")
G.save(c, NAME)
