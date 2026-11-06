-- ico-medal-bronze (Opus single pass, replaces the Sonnet draft). Third place as a heater shield: a pillow-bevelled
-- bronze shield with a recessed field (dark wall upper-left, lit lip lower-right) and a raised 3 with a drop shadow,
-- hung by a small jump ring from a horizontal clasp bar (lit cylinder) under a short, straight moss-green ribbon
-- with a cream centre stripe, twill weave and a dark ambient row where it tucks into the bars.
-- quirk: a little verdigris bloom has crept onto the lower-left of the shield rim.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA6_5.lua")
local HP, X, K = A.HP, A.X, A.K
local c = A.new("ico-medal-bronze")
local B = A.BRZ
local GRN = { "#1f4a40", "#2d6a48", "#3f8a50", "#5aa858", "#80c462", "#aadb7c" }
local CRM = { "#8a7a6a", "#b8a488", "#d8c6a2", "#eedcb6", "#f8ecca", "#fff4d6" }
local tr, tc, tm = A.tok("ribbon"), A.tok("stripe"), A.tok("bronze")

-- ribbon (y 9..24), stripe in the middle
local rib = HP.rect(23, 9, 41, 24)
A.strap(c, rib, 32, 9, 32, 24, 9.5, GRN, tr, { tp = 4 })
local str = HP.rect(30, 9, 34, 24)
A.strap(c, str, 32, 9, 32, 24, 2.5, CRM, tc, { tp = 99 })
-- 1px dark separators beside the stripe, ambient rows under the top bar / above the clasp
for y = 9, 24 do c:put(29, y, GRN[2], tr) c:put(35, y, GRN[1], tr) end
for x = 23, 41 do c:put(x, 9, (x >= 30 and x <= 34) and CRM[2] or GRN[1], tr) c:put(x, 24, (x >= 30 and x <= 34) and CRM[1] or GRN[1], tr) end
-- a soft horizontal fold across the ribbon
for x = 24, 40 do c:put(x, 16, (x >= 30 and x <= 34) and CRM[6] or GRN[5], tr) c:put(x, 17, (x >= 30 and x <= 34) and CRM[3] or GRN[3], tr) end

-- top pin bar and the clasp bar
A.bar(c, 21, 7.5, 43, 7.5, 1.6, B, tm)
A.bar(c, 20, 26, 44, 26, 1.7, B, tm)
for _, x in ipairs{ 20, 44 } do c:put(x, 25, B[3], tm) c:put(x, 27, B[2], tm) end
c:put(23, 25, B[6], tm) c:put(24, 25, B[6], tm)

-- jump ring between clasp and shield
local ring = c:ellipse(32, 29.5, 2, 1.5):cut(HP.rect(32, 29, 32, 30))
ring:each(function(x, y) c:put(x, y, (x < 32) and B[5] or B[2], tm) end)

-- shield
local sh = c:poly{ { 19.5, 31 }, { 25, 30.2 }, { 32, 31.2 }, { 39, 30.2 }, { 44.5, 31 }, { 44.5, 42 }, { 42.5, 48.5 },
  { 38.5, 53.5 }, { 32, 58 }, { 25.5, 53.5 }, { 21.5, 48.5 }, { 19.5, 42 } }
local sn, sd = X.pillow(sh, 3.2)
A.shade(c, sh, sn, B, { tok = tm, cuts = { 0.24, 0.42, 0.58, 0.72, 0.86 } })
local field = sh:shrink(3)
A.field(c, field, B, tm, { mid = 3 })
-- raised 3
local dg = A.digit(3, 28, 36)
A.emboss(c, dg, B, tm, field, { R = 1.3 })
-- specular streak on the upper-left bevel + glint
for _, p in ipairs{ { 21, 34 }, { 21, 35 }, { 21, 36 }, { 21, 37 }, { 22, 33 } } do c:put(p[1], p[2], B[6], tm) end
c:put(21, 35, A.CREAM, tm)

-- quirk: verdigris bloom on the lower-left rim
local VG = { "#2f6a6a", "#4a9a8a", "#7cc8a8", "#b0e6c4" }
local vg = c:ellipse(23.5, 49, 2, 2.5):clip(sh):cut(field)
vg:each(function(x, y) local g = (x - 23.5) + (y - 49) c:put(x, y, VG[g < -1.5 and 4 or (g < 0 and 3 or (g < 1.5 and 2 or 1))], tm) end)
c:put(27, 53, VG[2], tm) c:put(26, 53, VG[3], tm)
A.save(c, "ico-medal-bronze")
