-- salted-eggs (lean E2_06)
local NAME = "salted-eggs"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function R(v) return floor(v + 0.5) end
local function paint(m, ramp, rad, name, opt) opt = opt or {}
  local n = X.pillow(m, rad or 4); local tok = { r = { name = name } }
  local idx = X.tone(c, m, X.light(n, { amb = opt.amb or 0.08, wrap = opt.wrap or 0.25 }), ramp, { cuts = { 0.22, 0.4, 0.56, 0.72, 0.86 }, tok = tok })
  return n, idx, tok end
local function sel(m, fn) local o = HP.mask() m:each(function(x, y) if fn(x, y) then o:set(x, y) end end) return o end
local function spec(m, n, col, tok) local x, y = G.specAt(m, n, 30) if x then c:put(x, y, col, tok) end end
local CROCK = { "#3a2218", "#643a26", "#8e5a38", "#b47a4c", "#d49c68", "#ecc08c" }
local SALT = { "#6a7aa0", "#8e9ec0", "#b4c2de", "#d6e0f0", "#eef4fc", "#f6fbff" }
local EGG = { "#6e7a62", "#92a082", "#b8c4a2", "#d6dcc0", "#eceed6", "#fffff0" }
local YOLK = { "#b8500c", "#e07a14", "#f8a824", "#ffd040", "#ffec80" }
c:groundShadow(32, 58, 22, 3)
local cr = c:rrect(12, 38, 52, 57, 5)
paint(cr, CROCK, 8, "crock")
-- grooves + rim
for x = 14, 50 do c:put(x, 46, CROCK[2], { r = { name = "groove" } }) end
c:rect(11, 36, 53, 40):each(function(x, y) c:put(x, y, y == 36 and CROCK[5] or (y == 40 and CROCK[2] or CROCK[4]), { r = { name = "rim" } }) end)
-- salt heap
local heap = c:ellipse(32, 36, 19, 5)
local hn, hidx, ht = paint(heap, SALT, 4, "salt")
heap:each(function(x, y) if X.hash(x, y, 3) > 0.9 then c:put(x, y, SALT[6], ht) elseif X.hash(x, y, 5) > 0.9 then c:put(x, y, SALT[2], ht) end end)
-- eggs
local function egg(cx, cy, rx, ry, name)
  local m = G.oval(cx, cy, rx, ry, 0, 0.0)
  local n, idx, t = paint(m, EGG, 5, name)
  spec(m, n, "#f6fbff", t); return m, n, idx, t end
local e1 = egg(21, 28, 7, 9, "egg1")
local e2 = egg(43, 28, 7, 9, "egg2")
local e3, n3, i3, t3 = egg(32, 24, 8, 11, "egg3")
-- cracked front egg: jagged cut showing yolk
local cut = sel(e3, function(x, y) return y < 17 + ((x % 4 < 2) and 0 or 2) end)
local yk = c:ellipse(32, 18, 6, 4)
paint(yk, YOLK, 3, "yolk")
c:put(30, 16, "#fff8c0", { r = { name = "yolk" } })
for _, p in ipairs{ {26,16},{27,15},{28,17},{36,17},{37,15},{38,16} } do c:put(p[1], p[2], EGG[6], t3) end
-- hairline crack on egg 2 and salt grains in front
for _, p in ipairs{ {43,22},{44,24},{43,26},{45,28} } do c:put(p[1], p[2], EGG[1], { r = { name = "egg2" } }) end
for _, p in ipairs{ {18,37},{28,39},{40,38},{47,36} } do c:put(p[1], p[2], SALT[6], ht) end
G.save(c, NAME)
