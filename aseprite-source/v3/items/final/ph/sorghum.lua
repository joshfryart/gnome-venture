-- sorghum (lean D2o_2)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "sorghum" }
local function shade(m, ramp, R, bias, cuts) local n = X.pillow(m, R) return G.tone(c, m, X.light(n, { amb = 0.1, wrap = 0.25 }), ramp, cuts, bias) end
-- sorghum: dense droopy panicle of round rust-orange grains on a thin stalk, long sweeping leaf; one grain husk is pale and split (quirk)
local GR   = { "#4a1c1c", "#7a2a1e", "#a8401f", "#d0642a", "#ee9040", "#ffc870" }
local STEM = { "#3b5a30", "#587e3c", "#82a84c", "#b4cc74" }
local LEAF = { "#1b3b2c", "#255a38", "#32784a", "#4b9a50", "#74b85c", "#a4d070" }
c:groundShadow(32, 57, 9, 2)
-- leaf
local lm, ln, lT, lS = X.cyl(31, 52, 53, 36, function(t) if t > 0.985 then return -1 end return max(0.6, 3.4 * sin(pi * min(1, t * 0.95 + 0.05)) ^ 0.7) end)
G.tone(c, lm, X.light(ln, { amb = 0.12, wrap = 0.25 }), LEAF, { 0.2, 0.38, 0.55, 0.7, 0.86 })
lm:each(function(x, y) local k = K(x, y) if abs(lS[k]) < 0.18 and lT[k] < 0.92 then c:px(x, y, lS[k] <= 0 and LEAF[6] or LEAF[3]) end end)
-- stalk
local sm, sn, sT = X.cyl(32, 34, 31, 57, function(t) if t > 0.99 then return -1 end return 1.7 end)
G.tone(c, sm, X.light(sn, { amb = 0.14, wrap = 0.3 }), STEM, { 0.3, 0.6, 0.85 })
for _, y in ipairs{ 44, 52 } do c:fillMask(c:rect(30, y, 33, y), STEM[1]) end
-- panicle grains, top to bottom
local counts = { 2, 3, 4, 5, 5, 5, 5, 4, 3, 2 }
local pale = { 4, 5 }
for j = 0, 9 do
  local cnt = counts[j + 1]
  local y = 9 + 3 * j
  local cx = 33 + j * 0.25 - (j > 6 and (j - 6) * 0.6 or 0)
  for i = 0, cnt - 1 do
    local x = floor(cx - (cnt - 1) * 1.5 + i * 3 + 0.5)
    local r = GR
    if j == pale[1] and i == pale[2] - 1 then r = { "#a89878", "#c8b890", "#e4d6ac", "#f4e8c4", "#fff6dc", "#ffffee" } end
    c:px(x - 1, y, r[4]) c:px(x, y, r[4]) c:px(x + 1, y, r[3])
    c:px(x - 1, y - 1, r[5]) c:px(x, y - 1, r[4]) c:px(x + 1, y - 1, r[3])
    c:px(x - 1, y + 1, r[3]) c:px(x, y + 1, r[2]) c:px(x + 1, y + 1, r[2])
    c:px(x - 1, y - 1, r[6])
  end
end
-- split husk line on pale grain + awns
for _, p in ipairs{ {30, 6}, {33, 5}, {36, 7} } do c:px(p[1], p[2], GR[4]) end
c:px(33, 4, GR[5])
G.fin(c, "sorghum")
