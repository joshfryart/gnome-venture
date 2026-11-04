-- root_cellar-2 (first draft, Sonnet). Tier 2: a taller mound; the door gets a grey stone frame, a stovepipe vent
-- sprouts on the left and a little red flag flies on a stick on the right.
-- quirk: the flag is tied on with a bit of string that has come loose.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD13.lua")
local c = A.new("root_cellar-2")
c:groundShadow(32, 58, 23, 3)
local m = A.mound(c, { cx = 30, yb = 54, rx = 24, ry = 30, ramp = "moss", skew = 0 })
A.speck(c, m, { "#c4e07a", "#3f9150" }, .09, 5)
A.lit(c, c:rect(5, 54, 54, 56), "wood", 1.6)
-- vent pipe
local pipe = c:rect(15, 26, 19, 36)
A.lit(c, pipe, "stone", 1.8) A.lit(c, c:rect(13, 23, 21, 26), "stone", 1.5)
for x = 14, 20 do c:px(x, 26, "#444663") end
-- stone frame
local fr = A.archM(c, 30, 54, 10, 22)
A.lit(c, fr, "stone", 2.4, { amb = .12 })
for _, p in ipairs{ { 21, 44 }, { 21, 50 }, { 39, 42 }, { 39, 48 }, { 28, 33 }, { 34, 33 } } do c:px(p[1], p[2], "#74758c") c:px(p[1] + 1, p[2], "#74758c") end
A.door(c, 30, 54, 7, 18, "wood")
-- flag on a stick
A.rod(c, 47, 14, 47, 36, .8, "wood", { amb = .1 })
local fl = c:poly{ { 48, 14 }, { 58, 17 }, { 48, 21 } }
A.lit(c, fl, "ember", 1.5)
A.ln(c, 47, 20, 45, 25, "#fff4d6")
A.fin()
