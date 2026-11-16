-- Cob Scout (mh-cob-scout), perch 36x36, hand-built at size. Haiku first pass, c00.
-- quirk: notched tally stick in one husk hand.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(dir .. "/_haiku.lua")
local HP, P = M.HP, M.P
local c = M.canvas("mh-cob-scout-perch", 36)

c:groundShadow(18, 33, 7, 2)
c:part(c:poly{ { 11, 14 }, { 6, 24 }, { 8, 30 }, { 12, 26 }, { 13, 18 } }, "moss")
c:part(c:poly{ { 25, 14 }, { 30, 24 }, { 28, 30 }, { 24, 26 }, { 23, 18 } }, "moss")
local cob = c:ellipse(18, 20, 9, 11)
c:part(cob, "gold", { band = 2 })
cob:each(function(x, y)
  if (x + (y // 2) * 2) % 4 == 0 then c:put(x, y, P.gold.shade) end
end)
c:part(c:line({ { 27, 24 }, { 32, 15 } }, 1), "wood")
c:px(28, 22, P.ink) c:px(30, 19, P.ink)
c:eyeSmall(14, 18)
c:eyeSmall(20, 18)
c:px(17, 22, P.gold.deep) c:px(18, 22, P.gold.deep)
c:px(16, 24, P.ink) c:px(17, 25, P.ink) c:px(18, 25, P.ink) c:px(19, 24, P.ink)

M.done(c, "mh-cob-scout-perch")
