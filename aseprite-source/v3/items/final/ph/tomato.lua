local NAME = "tomato"
-- tomato: plump ripe slightly squat tomato with faint lobes and stem dimple, five-point green calyx and curly stem,
-- waxy window highlight, ground shadow. quirk: one dew drop and a tiny split at the shoulder.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.18, 0.34, 0.5, 0.66, 0.82 }
local RED = { "#4a1424", "#7a1c2c", "#a82a2a", "#d0402e", "#ec6a3e", "#ff9a62" }
local GRN = { "#163a35", "#1f553f", "#2b7046", "#3f8f4c", "#62ad55", "#93cb68" }
c:groundShadow(32, 57, 20, 3)
local m, n = G.oval(32, 38, 20, 16.5, 0, 1.0)
-- lobes: perturb the normals with 3 soft ribs so the fruit isn't a ball
m:each(function(x, y) local k = K(x, y) local v = n[k]
  local rib = sin((x - 32) * 0.55) * 0.18
  n[k] = { G.norm and select(1, G.norm(v[1] + rib, v[2], v[3])) or v[1], v[2], v[3] } end)
local tok = { r = { name = "fruit" } }
local idx, lv = G.toneN(c, m, n, RED, { tok = tok, cuts = CUTS, amb = 0.08, wrap = 0.25 })
-- stem dimple: dark ring around the calyx
m:each(function(x, y) local d = sqrt((x - 32) ^ 2 + ((y - 24) * 1.6) ^ 2) if d > 7 and d < 8.4 then c:put(x, y, RED[2], tok) end end)
-- ribs (dark creases)
for _, cx in ipairs{ 18, 46 } do for y = 28, 50 do local x = floor(cx + sin((y - 28) * 0.15) * 2 + (cx < 32 and 0 or 0)) if m:has(x, y) then c:put(x, y, RED[2], tok) end end end
-- waxy highlight: window streak upper-left
for _, p in ipairs{ {20,32},{21,31},{22,30},{23,29},{20,33},{21,32},{22,31},{20,34} } do if m:has(p[1], p[2]) then c:put(p[1], p[2], "#ffd8b8", tok) end end
c:put(21, 31, "#fff4e0", tok) c:put(20, 33, "#fff4e0", tok)
-- bounce light lower right
for _, p in ipairs{ {44,48},{43,49},{42,50},{45,46} } do if m:has(p[1], p[2]) then c:put(p[1], p[2], RED[4], tok) end end
-- quirk: tiny shoulder split + dew drop
for _, p in ipairs{ {41,27},{42,28},{42,29},{43,30} } do if m:has(p[1], p[2]) then c:put(p[1], p[2], "#f7c46a", tok) end end
c:put(41, 28, RED[1], tok) c:put(43, 31, RED[1], tok)
local dm, dn = G.oval(37, 43, 2.2, 2.6, 0, 1)
local dt = { r = { name = "drop" } }
X.tone(c, dm, X.light(dn, { amb = 0.1, wrap = 0.2 }), { "#6a2a5a", "#a83a50", "#d8605a", "#f09a86", "#ffd2bc", "#ffd2bc" }, { cuts = CUTS, tok = dt })
c:put(36, 42, "#fff8ee", dt) c:put(38, 45, "#7aa8c8", dt)
-- calyx: 5 sepals + stem
local function sepal(ax, ay, cx, cy, bx, by, w)
  local sm, sn = G.blade(ax, ay, cx, cy, bx, by, function(t) if t > 0.985 then return -1 end return max(0.4, w * (1 - t) ^ 0.7 * (0.5 + t)) end, { fold = 0.4 })
  G.toneN(c, sm, sn, GRN, { tok = { r = { name = "sep" .. ax .. bx .. by } }, cuts = CUTS, amb = 0.12, wrap = 0.22 })
end
sepal(32, 24, 22, 24, 14, 29, 2.6)
sepal(32, 24, 42, 24, 50, 29, 2.6)
sepal(32, 24, 26, 20, 19, 19, 2.2)
sepal(32, 24, 38, 20, 45, 19, 2.2)
sepal(32, 25, 31, 30, 29, 33, 2.2)
local km, kn = G.oval(32, 24, 3.2, 2.2, 0, 1)
X.tone(c, km, X.light(kn, { amb = 0.1, wrap = 0.25 }), GRN, { cuts = CUTS, tok = { r = { name = "hub" } } })
local sm, sn, ST = G.tube({ {32,23}, {32,16}, {34,11}, {38,10} }, function(t) return 1.5 - 0.4 * t end)
G.toneN(c, sm, sn, GRN, { tok = { r = { name = "stem" } }, cuts = CUTS })
G.save(c, NAME)
