-- harvest-trug (dC11 first draft): shallow boat-shaped wooden garden trug with slats, brass-wire rim and a slim arched handle.
-- quirk: a ladybird walks along the handle; two radishes sit in the trug.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC11.lua")
local c = D.new("harvest-trug")
local P = D.P
c:groundShadow(32, 57, 20, 3)
-- handle
local hm = D.tube(c, { {12,38},{14,6},{50,6},{52,38} }, function(t) return 1.5 end, "wood", 2)
-- radishes
for _, r in ipairs{ {26,37}, {34,36} } do
  D.part(c, D.ell(r[1], r[2] + 2, 4, 5), "petal", 3)
  D.ln(c, r[1], r[2] - 2, r[1] - 1, r[2] - 6, P.moss.base) D.ln(c, r[1], r[2] - 2, r[1] + 3, r[2] - 6, P.moss.shade)
  c:px(r[1], r[2] + 8, P.cream)
end
-- body
local body = c:poly{ {6,38},{58,38},{52,53},{12,53} }
D.part(c, body, "wood", 6)
-- slats
for _, y in ipairs{ 43, 48 } do for x = 8, 56 do if body:has(x, y) then c:px(x, y, P.wood.deep) end end end
for _, x in ipairs{ 15, 24, 33, 42, 50 } do for y = 39, 52 do if body:has(x, y) then c:px(x, y, (y < 43 and P.wood.shade) or P.wood.deep) end end end
-- rim
local rim = c:rrect(4, 36, 59, 39, 1)
D.part(c, rim, D.r4("#e2e0e6", "#aaa9b8", "#74758c", "#444663"), 1)
for x = 12, 56, 7 do c:px(x, 54, P.wood.deep) end
-- brass rivets
for _, p in ipairs{ {13,36},{51,36} } do c:px(p[1], p[2], P.gold.hi) end
-- ladybird on handle
c:fillMask(D.ell(31, 5, 2.2, 1.8), P.ember.base) c:px(30, 4, P.cream) c:px(31, 5, P.ink) c:px(33, 4, P.ink)
D.fin()
