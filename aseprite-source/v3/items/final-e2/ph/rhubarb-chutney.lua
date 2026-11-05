-- rhubarb-chutney (lean E2_06)
local NAME = "rhubarb-chutney"
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
local GLASS = { "#2a4a5e", "#3f6f86", "#5f9ab0", "#8cc4d0", "#bfe6e8", "#eafafa" }
local CHUT = { "#4a0f26", "#7a1836", "#a82446", "#cc3c52", "#e8627a", "#ff98a2" }
local CLOTH = { "#8e2a3a", "#b83c4a", "#d85a62", "#ee8584", "#fbb4ae", "#fff0e8" }
local CARD = { "#a08a68", "#c8b088", "#e2cfa6", "#f0e2bc", "#f8f0d4", "#fffbea" }
c:groundShadow(32, 57, 20, 3)
local jar = c:rrect(16, 26, 48, 56, 6)
local n, _, jt = paint(jar, GLASS, 8, "glass")
local fill = c:rrect(18, 31, 46, 54, 5)
local fn, fidx, ft = paint(fill, CHUT, 7, "chut")
fill:each(function(x, y) if fidx[K(x, y)] >= 3 and X.hash(x, y, 9) > 0.86 then c:put(x, y, CHUT[6], ft) end end)
-- glass rim + streak
for y = 34, 50 do c:put(20, y, GLASS[5], jt) end; c:put(20, 33, GLASS[6], jt); c:put(20, 51, GLASS[4], jt)
c:rect(18, 26, 46, 28):each(function(x, y) c:put(x, y, GLASS[4], jt) end)
-- cloth cover with gingham
local cl = c:poly{ { 14, 28 }, { 15, 18 }, { 22, 13 }, { 42, 13 }, { 49, 18 }, { 50, 28 }, { 44, 25 }, { 32, 27 }, { 20, 25 } }
local cn, cidx, ct = paint(cl, CLOTH, 6, "cloth")
cl:each(function(x, y) if (floor(x / 3) + floor(y / 3)) % 2 == 0 then c:put(x, y, CLOTH[cidx[K(x, y)] >= 4 and 6 or 4], ct) end end)
-- twine
c:rect(19, 26, 45, 27):each(function(x, y) c:put(x, y, (x % 2 == 0) and "#d8b070" or "#a67c44", { r = { name = "twine" } }) end)
c:put(33, 28, "#d8b070"); c:put(33, 29, "#a67c44"); c:put(34, 30, "#d8b070"); c:put(30, 29, "#a67c44"); c:put(29, 30, "#d8b070")
-- label with rhubarb stalk + leaf
local lab = c:rrect(22, 36, 42, 51, 1)
local ln, _, lt = paint(lab, CARD, 4, "label", { wrap = 0.1 })
for _, y in ipairs{ 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48 } do
  c:put(30 + floor((y - 38) / 5), y, y < 41 and "#7a1836" or "#d8486a", lt); c:put(31 + floor((y - 38) / 5), y, y < 41 and "#a82446" or "#f26b86", lt) end
for _, p in ipairs{ {29,38},{28,37},{27,38},{28,39},{31,37},{32,36},{33,37},{32,38} } do c:put(p[1] + 0, p[2], "#4f9a48", lt) end
c:put(28, 38, "#8cc860", lt); c:put(32, 37, "#8cc860", lt)
-- quirk: chutney drip down the jar side
for y = 29, 36 do c:put(44, y, CHUT[3], ft) c:put(45, y, CHUT[2], ft) end
c:put(44, 37, CHUT[4], ft); c:put(44, 38, CHUT[5], ft)
c:put(23, 30, "#f6fbff", jt)
G.save(c, NAME)
