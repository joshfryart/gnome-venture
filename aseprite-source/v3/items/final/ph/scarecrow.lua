-- scarecrow (first draft, Sonnet). A stick figure on a wooden post: burlap sack head with a stitched smile and
-- button eyes, wide straw hat, cross-pole arms with straw tufts at the cuffs, a patched blue tunic.
-- quirk: a small black crow perches on its right arm and wears a tiny straw wisp.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD14.lua")
local c = A.new("scarecrow")
local floor = math.floor
c:groundShadow(32, 60, 11, 2)
-- post
A.rod(c, 32, 22, 32, 60, 1.6, "wood", { amb = .1 })
-- arms (cross-pole)
A.rod(c, 10, 28, 54, 28, 1.7, "wood", { amb = .1 })
-- sleeves / tunic
local tun = c:poly{ { 22, 26 }, { 42, 26 }, { 45, 48 }, { 19, 48 } }
A.lit(c, tun, A.R("#4f78b8"), 3, { amb = .1 })
for x = 22, 42, 4 do for y = 28, 46, 1 do if (x + y) % 8 == 0 then c:px(x + (y % 2), y, "#3a5a96") end end end
local slv = c:rect(12, 25, 22, 31)
A.lit(c, slv, A.R("#4f78b8"), 2, {})
A.lit(c, c:rect(42, 25, 52, 31), A.R("#4f78b8"), 2, {})
-- patch
c:fillMask(c:rect(35, 36, 40, 41), "#e8b982") c:px(35, 36, "#ffe0bd") c:px(40, 41, "#b97a4a") c:px(37, 38, "#b97a4a")
-- straw tufts
for _, h in ipairs{ { 10, 28, -1 }, { 54, 28, 1 }, { 32, 49, 0 } } do
  for i = -2, 2 do A.ln(c, h[1], h[2], h[1] + h[3] * 4 + i * 2, h[2] + (h[3] == 0 and 6 or 5), i % 2 == 0 and "#f5b82e" or "#ffe38a") end
end
-- head sack
A.sph(c, 32, 17, 7, "#d8b88a", { nospec = true })
c:px(29, 17, "#2b1c26") c:px(30, 17, "#2b1c26") c:px(34, 17, "#2b1c26") c:px(35, 17, "#2b1c26")
c:px(29, 16, "#fff4d6")
for x = 29, 35 do c:px(x, 21 - (x % 2), "#2b1c26") end
c:px(32, 19, "#b88a56") c:px(33, 19, "#8a5a36")
-- hat
local brim = c:ellipse(32, 12, 14, 3)
A.lit(c, brim, A.R("#e8b982"), 2, {})
local crown = c:rrect(24, 3, 40, 12, 3)
A.lit(c, crown, A.R("#e8b982"), 3, {})
c:fillMask(c:rect(24, 9, 40, 10), "#b5654a")
-- crow
local crowb = c:ellipse(48, 22, 5, 3.4)
A.lit(c, crowb, A.R("#4a3a6a"), 2, { amb = .06 })
A.sph(c, 52, 19, 2.4, "#4a3a6a", { nospec = true })
c:px(51, 18, "#fff4d6") c:px(55, 20, "#f5b82e") c:px(56, 20, "#d98322")
c:fillMask(c:poly{ { 43, 22 }, { 38, 26 }, { 44, 24 } }, "#35295f")
c:px(47, 26, "#d98322") c:px(49, 26, "#d98322")
c:px(52, 16, "#f5b82e") c:px(53, 15, "#ffe38a")
A.fin()
