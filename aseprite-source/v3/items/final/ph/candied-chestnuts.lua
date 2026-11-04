-- candied-chestnuts (lean W2_0)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function egg(cx, y0, y1, w, pw) local m = HP.mask() for y = y0, y1 do local t = (y - y0) / (y1 - y0); local h = w * sin(pi * t ^ pw) ^ 0.8 + 0.5; for x = floor(cx - h + 0.5), floor(cx + h - 0.5) do m:set(x, y) end end return m end
local function shade(c, m, R, ramp, bias, o) local n = X.pillow(m, R); return n, G.tone(c, m, X.light(n, o or { amb = 0.1, wrap = 0.25 }), ramp, nil, bias) end

local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "candied-chestnuts" }
local GL = { "#4a1f10", "#7a3a14", "#a85a1c", "#d08428", "#eeb04a", "#ffd985" }
local PAP = { "#8f7fa8", "#b4a6c4", "#d9cfdb", "#f1ebec", "#fffaf2" }
local RB = { "#5c1226", "#8a1d3a", "#b83150", "#e0566e" }
c:groundShadow(32, 57, 21, 3)
-- three glazed marrons
local function marron(cx, cy, r, sd)
  local m = egg(cx, cy - r, cy + r - 1, r + 0.5, 0.8)
  local bias = {}
  m:each(function(x, y) local k = K(x, y)
    if (x + floor(y * 0.5)) % 4 == 0 and X.hash(x, y, sd) > 0.5 then bias[k] = -1 end end)
  local n = X.pillow(m, r + 1)
  G.tone(c, m, X.light(n, { amb = 0.1, wrap = 0.3 }), GL, nil, bias)
  c:px(cx - r // 2 - 1, cy - r // 2, "#fffbe6") c:px(cx - r // 2, cy - r // 2 - 1, "#fffbe6") c:px(cx - r // 2 - 1, cy - r // 2 + 1, GL[6])
  c:px(cx, cy - r, GL[2]) c:px(cx, cy - r - 1, "#c9a45c")
end
marron(32, 22, 9, 1)
marron(21, 33, 8, 2)
marron(43, 33, 8, 3)
-- pleated paper cup
local cup = HP.mask()
for y = 36, 55 do local t = (y - 36) / 19; local h = 17 - 6 * t; for x = floor(32 - h + 0.5), floor(32 + h - 0.5) do cup:set(x, y) end end
local cn = X.pillow(cup, 20)
G.tone(c, cup, X.light(cn, { amb = 0.3, wrap = 0.4 }), PAP, { 0.2, 0.4, 0.62, 0.82 })
cup:each(function(x, y) if (x % 3 == 0) and y > 38 then c:px(x, y, x < 32 and PAP[2] or PAP[1]) end end)
-- ruffled rim
for x = 15, 49 do local y = 36 + ((x % 3 == 1) and -1 or 0); c:px(x, y, PAP[5]); c:px(x, y + 1, PAP[3]) end
-- ribbon band with bow
c:fillMask(c:rect(14, 46, 50, 48), RB[2]) c:fillMask(c:rect(14, 46, 50, 46), RB[4]) c:fillMask(c:rect(14, 48, 50, 48), RB[1])
c:fillMask(c:ellipse(28, 47, 3, 2.2), RB[3]) c:fillMask(c:ellipse(36, 47, 3, 2.2), RB[3])
c:fillMask(c:rect(31, 46, 33, 48), RB[2]) c:px(31, 46, RB[4])
c:line({ {32, 49}, {30, 53} }, 1):each(function(x, y) c:px(x, y, RB[3]) end)
c:line({ {33, 49}, {35, 53} }, 1):each(function(x, y) c:px(x, y, RB[2]) end)
-- sugar crystals (quirk) and a syrup drip
for _, p in ipairs{ {12, 28}, {50, 26}, {30, 14}, {36, 8}, {17, 25}, {47, 38} } do c:sparkle(p[1], p[2]) end
c:fillMask(c:rect(40, 40, 40, 44), GL[4]) c:px(40, 45, GL[5]) c:px(40, 45, GL[3])
G.fin(c, "candied-chestnuts")
