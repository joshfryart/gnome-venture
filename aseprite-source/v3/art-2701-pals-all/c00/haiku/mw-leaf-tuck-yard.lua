-- Leaf Tuck (mw-leaf-tuck), yard 64x64. Haiku first pass, c00. Bloomcaller, common, Maplewold.
-- A red maple-leaf creature with a flap tucked over its right side, showing the moss-green underside.
-- quirk: the tucked flap (green underside) and a leaf stalk on top.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(dir .. "/_haiku.lua")
local HP, P = M.HP, M.P
local c = M.canvas("mw-leaf-tuck-yard", 64)

c:groundShadow(32, 58, 15, 3)
c:part(c:line({ { 32, 11 }, { 34, 4 } }, 1), "moss")
local leaf = c:poly{ { 32, 10 }, { 40, 17 }, { 47, 23 }, { 50, 32 }, { 46, 44 }, { 36, 54 }, { 32, 56 },
                     { 28, 54 }, { 18, 44 }, { 14, 32 }, { 17, 23 }, { 24, 17 } }
c:part(leaf, "ember")
-- midrib on the left half
for _, p in ipairs({ { 31, 14 }, { 31, 15 }, { 30, 16 }, { 30, 17 }, { 30, 18 }, { 30, 19 }, { 30, 20 }, { 29, 21 }, { 29, 22 } }) do
  c:px(p[1], p[2], P.ember.deep)
end
-- tucked flap on the right, green underside showing
c:part(c:poly{ { 43, 22 }, { 48, 30 }, { 49, 40 }, { 44, 46 }, { 42, 38 } }, "moss", { band = 2 })
-- face
c:eyeLocked(22, 31)
c:eyeLocked(38, 31)
c:cheek(20, 38) c:cheek(40, 38)
c:px(31, 37, P.ember.hi) c:px(32, 37, P.ember.hi)
c:px(31, 38, P.ember.deep) c:px(32, 38, P.ember.deep)
for _, p in ipairs({ { 29, 40 }, { 30, 41 }, { 31, 41 }, { 32, 41 }, { 33, 41 }, { 34, 40 } }) do c:px(p[1], p[2], P.ink) end

M.done(c, "mw-leaf-tuck-yard")
