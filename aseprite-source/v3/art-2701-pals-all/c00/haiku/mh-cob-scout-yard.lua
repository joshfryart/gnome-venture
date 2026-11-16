-- Cob Scout (mh-cob-scout), yard 64x64. Haiku first pass, c00. Wayfinder, common, Maizehollow.
-- A plump corn cob with kernel rows and green husk leaves for arms.
-- quirk: a notched tally stick in one husk hand, counting kernel rows.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(dir .. "/_haiku.lua")
local HP, P = M.HP, M.P
local c = M.canvas("mh-cob-scout-yard", 64)

c:groundShadow(32, 58, 15, 3)
-- husk leaves behind the cob
c:part(c:poly{ { 22, 30 }, { 12, 44 }, { 14, 56 }, { 24, 50 }, { 26, 38 } }, "moss")
c:part(c:poly{ { 42, 30 }, { 52, 44 }, { 50, 56 }, { 40, 50 }, { 38, 38 } }, "moss")
-- cob body with kernel rows
local cob = c:ellipse(32, 36, 15, 20)
c:part(cob, "gold", { band = 3 })
cob:each(function(x, y)
  if (x + (y // 3) * 2) % 4 == 0 then c:put(x, y, P.gold.shade) end
end)
-- tally stick with notches (quirk)
c:part(c:line({ { 46, 40 }, { 56, 22 } }, 1), "wood")
for _, p in ipairs({ { 49, 36 }, { 51, 32 }, { 53, 29 } }) do c:px(p[1], p[2], P.ink) end
-- face
c:eyeLocked(24, 31)
c:eyeLocked(36, 31)
c:cheek(21, 37) c:cheek(40, 37)
c:px(31, 36, P.gold.hi) c:px(32, 36, P.gold.hi)
c:px(31, 37, P.gold.deep) c:px(32, 37, P.gold.deep)
for _, p in ipairs({ { 29, 40 }, { 30, 41 }, { 31, 41 }, { 32, 41 }, { 33, 41 }, { 34, 40 } }) do c:px(p[1], p[2], P.ink) end

M.done(c, "mh-cob-scout-yard")
