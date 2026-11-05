-- starlight-hammock (lean P1b_O13)
local NAME = "starlight-hammock"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function T(nm) return { r = { name = nm } } end
local WOOD = { "#2e1a14", "#4c2c1e", "#6e4428", "#946238", "#b88450", "#dcaa72" }
local NAVY = { "#10163e", "#1c2a72", "#2c46a8", "#4468d0", "#6c92ec", "#a8c4ff" }
local ROPE = { "#6a4a28", "#a07a44", "#d2a864", "#f0d08c" }
c:groundShadow(32, 57, 26, 3)
-- posts
local function post(x0, x1)
  local m = c:rrect(x0, 8, x1, 55, 1)
  local n = X.pillow(m, 3.5)
  G.toneN(c, m, n, WOOD, { tok = T("post"), cuts = {0.2,0.38,0.55,0.72,0.88}, amb = 0.12, wrap = 0.3 })
  m:each(function(x, y) local h = X.hash(x, floor(y / 3), 9)
    if x == x0 + 1 and h > 0.4 then c:put(x, y, WOOD[2], T("post")) end
    if x == x1 - 1 and h > 0.55 then c:put(x, y, WOOD[5], T("post")) end end)
  c:fillMask(c:rect(x0, 8, x1, 9), WOOD[5]) c:put(x0, 8, WOOD[6], T("post")) c:put(x0 + 1, 8, WOOD[6], T("post"))
  c:fillMask(c:rect(x0, 52, x1, 55), WOOD[2]) c:put(x0, 52, WOOD[3], T("post"))
end
post(8, 13) post(50, 55)
-- hammock cloth
local cloth = HP.mask()
local top, bot = {}, {}
for x = 14, 49 do
  local u = (x - 31.5) / 17.5
  top[x] = floor(17 + 18 * (1 - u * u) + 0.5)
  bot[x] = floor(top[x] + 3 + 9 * (1 - u ^ 4) + 0.5)
  for y = top[x], bot[x] do cloth:set(x, y) end
end
local n = X.pillow(cloth, 7)
G.toneN(c, cloth, n, NAVY, { tok = T("cloth"), cuts = {0.18,0.34,0.5,0.66,0.84}, amb = 0.1, wrap = 0.3 })
-- light rim band along the top edge, weave
cloth:each(function(x, y)
  if y == top[x] or y == top[x] + 1 then c:put(x, y, y == top[x] and NAVY[5] or NAVY[4], T("cloth")) end
  if (x + y) % 4 == 0 and y > top[x] + 1 and y < bot[x] then c:put(x, y, NAVY[2], T("cloth")) end
  if y == bot[x] then c:put(x, y, NAVY[1], T("cloth")) end
end)
-- stars on the cloth
local function star(x, y, hexA, hexB) c:put(x, y, hexA, T("star")) for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if cloth:has(x + d[1], y + d[2]) then c:put(x + d[1], y + d[2], hexB, T("star")) end end end
star(22, 30, "#fff6b0", "#f0c830") star(30, 40, "#fff6b0", "#f0c830") star(40, 36, "#fff6b0", "#f0c830") star(35, 31, "#fff6b0", "#e8b020") star(26, 38, "#ffe27a", "#c89a18")
-- rope wraps and knots at both posts
for _, side in ipairs{ {14, 17}, {44, 49} } do
  for x = side[1], side[2] do local y = top[x] - 1 + 0 c:put(x, y, ROPE[3], T("rope")) end
end
for _, p in ipairs{ {13,15},{13,16},{12,16},{50,15},{50,16},{51,16} } do c:put(p[1], p[2], ROPE[2], T("rope")) end
for _, p in ipairs{ {13,17},{14,17},{13,18},{50,17},{49,17},{50,18} } do c:put(p[1], p[2], ROPE[1], T("rope")) end
c:put(12, 15, ROPE[4], T("rope")) c:put(51, 15, ROPE[4], T("rope"))
-- fringe tassels at the low belly
for x = 28, 35, 2 do c:put(x, bot[x] + 1, "#f0c830", T("fr")) c:put(x, bot[x] + 2, "#c89a18", T("fr")) end
-- quirk: dangling crescent moon charm
c:put(32, bot[32] + 1, ROPE[3], T("th")) c:put(32, bot[32] + 2, ROPE[3], T("th"))
local moon = HP.mask() moon:add(c:ellipse(32, bot[32] + 6, 3, 3)) moon:cut(c:ellipse(34, bot[32] + 5, 3, 3))
G.toneN(c, moon, X.pillow(moon, 2), { "#c89a18", "#f0c830", "#ffe27a", "#fffbc8" }, { tok = T("moon"), cuts = {0.3,0.6,0.85} })
G.save(c, NAME)
