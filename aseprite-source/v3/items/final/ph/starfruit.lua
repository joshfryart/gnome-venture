-- starfruit (lean P1b_O13)
local NAME = "starfruit"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt, atan2 = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local function T(nm) return { r = { name = nm } } end
local function ball(m, R, ramp, nm, o) local n = X.pillow(m, R) o = o or {} o.tok = T(nm) if not o.cuts then o.cuts = {0.2,0.38,0.55,0.72,0.86} end G.toneN(c, m, n, ramp, o) return n end
local YEL = { "#7a4a10", "#c47a14", "#ecaa22", "#f8d23c", "#fff08a", "#fffbc8" }
c:groundShadow(32, 57, 24, 3)
-- whole fruit: three ridge lobes along a horizontal axis
local lobes = { {26,18,19,5.5}, {26,25,21,7}, {26,32,19,5.5} }
local all = HP.mask()
for i, L in ipairs(lobes) do
  local m, n = G.oval(L[1], L[2], L[3], L[4], 0, 1.3)
  all:add(m)
end
for i = 1, 3 do
  local L = lobes[i]
  local m, n = G.oval(L[1], L[2], L[3], L[4], 0, 1.3)
  local own = m:copy()
  for j = i + 1, 3 do local o = G.oval(lobes[j][1], lobes[j][2], lobes[j][3], lobes[j][4], 0, 1.3) own:cut(o) end
  G.toneN(c, own, n, YEL, { tok = T("fruit"), cuts = {0.22,0.4,0.56,0.72,0.88}, amb = 0.08, wrap = 0.3 })
end
-- orange-brown ridge edges, green tinted ends
all:each(function(x, y)
  if not all:has(x, y - 1) or not all:has(x, y + 1) then if X.hash(x, y, 2) > 0.3 then c:put(x, y, YEL[2], T("fruit")) end end
  if x < 10 or x > 40 then c:put(x, y, (x < 8 or x > 43) and "#7ab43a" or "#b8c83a", T("fruit")) end
end)
for _, y in ipairs{ 22, 29 } do for x = 12, 40 do if X.hash(x, y, 6) > 0.35 then c:put(x, y, YEL[2], T("fruit")) end end end
-- waxy spec
for _, p in ipairs{ {16,19},{17,19},{18,19},{15,20},{19,26},{20,26},{16,27} } do c:put(p[1], p[2], "#fffdf0", T("fruit")) end
-- stem nub
for _, p in ipairs{ {5,24},{6,24},{5,25},{6,25},{4,26},{5,26} } do c:put(p[1], p[2], p[1] == 4 and "#5a3a1c" or "#8a5a2a", T("stem")) end
c:put(6, 24, "#b88a50", T("stem"))
-- star slice
local sx, sy = 44, 43
local pts = {}
for i = 0, 9 do local a = -pi / 2 + i * pi / 5 local r = (i % 2 == 0) and 13 or 6.5 pts[#pts + 1] = { sx + r * cos(a), sy + r * sin(a) } end
local st = c:poly(pts)
local FL = { "#d8a820", "#eec838", "#f8e068", "#fff29a", "#fffbd0" }
G.toneN(c, st, X.pillow(st, 5), FL, { tok = T("slice"), cuts = {0.3,0.55,0.8}, amb = 0.3, wrap = 0.5 })
local rim = st:edge()
rim:each(function(x, y) c:put(x, y, (x + y) % 3 == 0 and "#c8e050" or "#8cc43a", T("slice")) end)
for i = 0, 4 do local a = -pi / 2 + i * 2 * pi / 5 + pi / 5
  for r = 2, 6 do c:put(floor(sx + r * cos(a) + 0.5), floor(sy + r * sin(a) + 0.5), "#d8b028", T("slice")) end
  c:put(floor(sx + 5 * cos(a - pi / 5) + 0.5), floor(sy + 5 * sin(a - pi / 5) + 0.5), "#7a4a10", T("slice")) end
c:put(sx - 4, sy - 5, "#ffffe8", T("slice")) c:put(sx - 3, sy - 5, "#ffffe8", T("slice"))
-- quirk: juice drip
c:put(48, 56, "#fff08a", T("drip")) c:put(48, 57, "#ecaa22", T("drip"))
G.save(c, NAME)
