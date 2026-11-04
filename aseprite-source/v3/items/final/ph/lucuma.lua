-- lucuma (lean W2_9)
-- Upright pointed-teardrop fruit, olive skin with pale lenticel specks; a scooped round window shows orange mealy flesh
-- around one big glossy brown seed. Short woody stem + veined leaf. Quirk: seed has a pale scar.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "lucuma" }
local SKIN = { "#2e3f1e", "#4a5e26", "#6d7f33", "#93a043", "#b7bf62", "#dce08c" }
local FLESH = { "#a8481c", "#d06a1a", "#ee8f1c", "#fbb42e", "#ffd25a", "#fff0a0" }
local SEED = { "#2a1510", "#4a2618", "#6d3a22", "#935230", "#b87444", "#e0a878" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
c:groundShadow(32, 56, 12, 2)
-- leaf
local lm, ln, lT, lS = G.tube({ {33,17}, {38,9}, {46,8}, {54,13} }, function(t) return 0.7 + 4.2 * sin(pi * min(1, t * 1.05)) ^ 0.7 end)
G.tone(c, lm, X.light(ln, { amb = 0.12, wrap = 0.25 }), LEAF, nil)
lm:each(function(x, y) local k = K(x, y)
  if abs(lS[k]) < 0.18 and lT[k] > 0.1 and lT[k] < 0.92 then c:px(x, y, lS[k] <= 0 and LEAF[6] or LEAF[3]) end
  if lT[k] > 0.3 then for _, vt in ipairs{0.4,0.55,0.7,0.84} do
    local d = (lT[k] - vt) * 24 - abs(lS[k]) * 2.2
    if d > -0.5 and d < 0.5 and abs(lS[k]) > 0.3 then c:px(x, y, lS[k] < 0 and LEAF[5] or LEAF[2]) end end end
end)
-- stem
local sm, sn = G.tube({ {32,23}, {31,20}, {32,18}, {33,16} }, function(t) return 1.6 - 0.4 * t end)
G.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), SEED, nil)
-- body
local cx, y0, y1 = 31, 20, 55
local function hw(y) local t = (y - y0) / (y1 - y0)
  if t < 0.45 then return 13 * sin(min(1, (t + 0.05) / 0.5) * pi / 2) ^ 0.55 end
  return 13 * ((1 - t) / 0.55) ^ 0.8 + 0.3 end
local body = HP.mask()
for y = y0, y1 do local h = hw(y) for x = floor(cx - h + 0.5), floor(cx + h - 0.5) do body:set(x, y) end end
local n = X.pillow(body, 12)
local v = X.light(n, { amb = 0.06, wrap = 0.2 })
local win = c:ellipse(38, 37, 7, 10)
local flesh = win:copy():clip(body)
local ring = win:copy():grow(1):clip(body):cut(flesh)
local skin = body:copy():cut(flesh):cut(ring)
local bias = {}
X.ao(bias, skin, flesh, 2, -1)
G.tone(c, skin, v, SKIN, { 0.2, 0.38, 0.54, 0.7, 0.86 }, bias)
skin:each(function(x, y) if v[K(x, y)] > 0.5 and X.hash(x, y, 5) > 0.9 then c:px(x, y, SKIN[6]) end
  if v[K(x, y)] < 0.4 and X.hash(x, y, 8) > 0.93 then c:px(x, y, SKIN[1]) end end)
ring:each(function(x, y) c:px(x, y, (x + y) % 3 == 0 and "#f4eaa0" or "#d8d27a") end)
local fn = X.pillow(flesh, 9)
G.tone(c, flesh, X.light(fn, { amb = 0.2, wrap = 0.4 }), FLESH, nil)
flesh:each(function(x, y) if X.hash(x, y, 3) > 0.9 then c:px(x, y, FLESH[5]) end end)
-- seed
local sd = c:ellipse(38, 38, 4, 6):clip(flesh)
local sdn = X.pillow(sd, 5)
local sb = {}
X.ao(sb, sd, HP.mask(), 1, 0)
G.tone(c, sd, X.light(sdn, { amb = 0.1, wrap = 0.2 }), SEED, nil)
c:px(36, 35, SEED[6]) c:px(37, 35, SEED[6]) c:px(36, 36, SEED[5])
for _, p in ipairs{ {38,43},{39,43},{38,44} } do c:px(p[1], p[2], "#d9c9a8") end -- scar quirk
-- spec on skin
c:px(24, 28, SKIN[6]) c:px(25, 28, SKIN[6]) c:px(24, 29, SKIN[5])
G.fin(c, "lucuma")
