-- tepache (lean D3o_1)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function clampi(i, a, b) if not b then a, b = 1, a end return max(a, min(b, i)) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "tepache" }
local GL   = { "#4f7f96", "#7fb0c4", "#a9d6e0", "#cdeaf0", "#e6f6f8", "#f4fcff" }
local AMB  = { "#7a3b12", "#b25e14", "#d98a1c", "#f0b22e", "#ffd35a", "#fff0a0" }
local PINE = { "#7a5a10", "#b88a18", "#e0b628", "#f8d848", "#fff09a" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
c:groundShadow(32, 56, 17, 3)
local B = c:ellipse(32, 41, 16, 14)
local glass = B:copy():add(c:rect(25, 17, 39, 30)):add(c:rect(23, 15, 41, 18))
local n = X.pillow(glass, 8)
local v = X.light(n, { amb = 0.15, wrap = 0.3 })
G.tone(c, glass, v, GL, { 0.2, 0.35, 0.5, 0.65, 0.8 })
local inner = B:copy():shrink(2):add(c:rect(27, 19, 37, 30))
local liq = inner:copy():cut(c:rect(0, 0, 63, 30))
local air = inner:copy():cut(liq)
air:each(function(x, y) c:px(x, y, (x + y) % 5 == 0 and GL[5] or GL[4]) end)
local ln = X.pillow(liq, 10)
local lv = X.light(ln, { amb = 0.12, wrap = 0.3 })
G.tone(c, liq, lv, AMB, { 0.2, 0.38, 0.55, 0.72, 0.88 })
-- foam
for x = 18, 46 do if liq:has(x, 31) and X.hash(x, 31, 2) > 0.35 then c:px(x, 31, AMB[6]) end end
-- pineapple rind chunks
local function chunk(cx, cy)
  local m = c:poly{ {cx, cy - 3}, {cx + 4, cy}, {cx, cy + 3}, {cx - 4, cy} }
  m:each(function(x, y)
    local i = 3 + ((x - cx) < 0 and 1 or 0) - ((y - cy) > 0 and 1 or 0)
    if (x + y) % 3 == 0 then i = i - 1 end
    c:px(x, y, PINE[clampi(i, 1, 5)])
  end)
  m:edge():each(function(x, y) if (x - cx) > 0 and (y - cy) >= 0 then c:px(x, y, PINE[1]) end end)
end
chunk(27, 44) chunk(38, 48) chunk(34, 38)
-- bubbles
for _, p in ipairs{ {24,39}, {40,40}, {30,50}, {41,45}, {23,47}, {36,33} } do
  c:px(p[1], p[2], AMB[6]) c:px(p[1] + 1, p[2], AMB[5]) c:px(p[1], p[2] + 1, AMB[3])
end
-- glass streaks
for y = 37, 47 do c:px(19, y, GL[6]) end
c:px(20, 36, GL[6]) c:px(20, 48, GL[5])
for y = 20, 27 do c:px(26, y, GL[6]) end
c:px(24, 16, GL[6]) c:px(25, 16, GL[6])
-- quirk: pineapple crown stuffed in the neck
local function frond(tx, ty)
  local P = { {32, 23}, {32 + (tx - 32) * 0.3, 23 + (ty - 23) * 0.4}, {32 + (tx - 32) * 0.7, 23 + (ty - 23) * 0.8}, {tx, ty} }
  local m, nn = G.tube(P, function(t) return 2.5 * (1 - t) ^ 0.9 + 0.35 end)
  G.tone(c, m, X.light(nn, { amb = 0.12, wrap = 0.25 }), LEAF)
end
frond(20, 12) frond(44, 12) frond(25, 7) frond(39, 7) frond(32, 6)
c:px(30, 18, LEAF[1]) c:px(34, 18, LEAF[1])
G.fin(c, "tepache")
