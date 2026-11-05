-- sprinkler-can (lean E2_08)
local NAME = "sprinkler-can"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.86 }
local function blob(m, ramp, name, R, o)
  o = o or {}
  local n = X.pillow(m, R or 3)
  local tok = { r = { name = name } }
  return X.tone(c, m, X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.22 }), ramp, { cuts = CUTS, tok = tok }), n, tok
end
local function put(x, y, col, name) c:put(floor(x + .5), floor(y + .5), col, { r = { name = name or "d" } }) end
local function dots(m, col, name) m:each(function(x, y) c:put(x, y, col, { r = { name = name or "d" } }) end) end

local TEAL = { "#12343a", "#1c5a60", "#2a8078", "#3fa58c", "#6ccaa0", "#b4efc6" }
local BRASS = { "#4a2c14", "#7a4c1c", "#b0782a", "#d8a040", "#f0c868", "#fff0a8" }
local WATER = { "#1e3a78", "#2f5fb0", "#4a8ee0", "#8cc4f4", "#d8f0ff" }
local LEAF = { "#163a35", "#1f553f", "#2b7046", "#3f8f4c", "#62ad55", "#93cb68" }
c:groundShadow(28, 57, 21, 3)
-- handle (loop at the back)
local hm, hn = G.tube({ {16,28}, {5,28}, {4,44}, {15,50} }, function(t) return 1.9 end)
blob(hm, BRASS, "handle", 2)
-- spout
local sm = G.tube({ {38,48}, {47,46}, {49,34}, {53,25} }, function(t) return 2.3 - 0.9 * t end)
blob(sm, TEAL, "spout", 2)
-- body
local body = c:rrect(14, 27, 40, 53, 3)
local _, bn, btok = blob(body, TEAL, "body", 10, { wrap = 0.3 })
-- bands
for x = 14, 40 do if body:has(x, 31) then put(x, 31, TEAL[1], "band") end if body:has(x, 32) then put(x, 32, BRASS[4], "band") end
  if body:has(x, 47) then put(x, 47, BRASS[3], "band") end if body:has(x, 48) then put(x, 48, TEAL[1], "band") end end
-- rivets + ribs
for _, y in ipairs{ 36, 43 } do for x = 18, 36, 6 do put(x, y, TEAL[6], "rivet") put(x + 1, y + 1, TEAL[1], "rivet") end end
-- opening on top with water
local lip = c:ellipse(27, 26, 13, 3)
blob(lip, BRASS, "lip", 3)
local wat = c:ellipse(27, 26, 10, 2)
dots(wat, WATER[2], "water")
for x = 21, 28 do put(x, 25, WATER[3], "water") end put(23,25,WATER[5])
-- quirk: a seedling poking out of the opening
local st = c:line({ {28,25}, {28,20}, {29,15} }, 1)
dots(st, LEAF[4], "sprout")
local l1 = G.blade(28, 18, 22, 11, 20, 14, function(t) if t > .98 then return -1 end return max(.5, 2.6 * sin(pi * t) ^ .8) end)
local l2 = G.blade(29, 16, 36, 9, 38, 13, function(t) if t > .98 then return -1 end return max(.5, 2.6 * sin(pi * t) ^ .8) end)
blob(l1, LEAF, "sl1", 2) blob(l2, LEAF, "sl2", 2)
-- rose (sprinkler head), angled
local rose = c:ellipse(55, 21, 4, 5)
local _, rn, rtok = blob(rose, BRASS, "rose", 4)
for _, p in ipairs{ {56,19},{57,21},{56,23},{58,18},{58,24} } do if rose:has(p[1], p[2]) then put(p[1], p[2], BRASS[1], "hole") end end
put(53,18,BRASS[6]) put(53,19,BRASS[6])
-- drops
for _, d in ipairs{ {59,27}, {58,32}, {60,38}, {57,44} } do
  put(d[1], d[2], WATER[3], "drop") put(d[1], d[2] + 1, WATER[2], "drop") put(d[1] - 1, d[2], WATER[5], "drop")
end
put(17,34,TEAL[6]) put(17,35,TEAL[6]) put(18,33,TEAL[6])
c:sparkle(33, 38)
G.save(c, NAME)
