-- broken-prospector-s-pick (aB12_2, Opus single pass). Front view: slim arched double-pointed steel head on a
-- vertical ash handle, wedged end grain showing above the eye. Material: bevelled steel with a sheen streak and one
-- specular, wood grain + pale end grain on the handle, AO where head meets handle.
-- broken: the right pick arm snapped off near its tip (the tip drops away), a split runs up the handle foot, a steel chip flies.
-- quirk: a little indigo bandana knotted under the head, tails fluttering.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB12_2.lua")
local HP, X, K = A.HP, A.X, A.K
local c = A.new("broken-prospector-s-pick")
local BAND = { "#1f2550", "#2a3a7a", "#3a5aa8", "#5a82d0", "#86aee8", "#bcd6f6" }

local head = function(t) return 8 + 48 * t, 22 - 13 * math.sin(math.pi * t) end
local hw = function(t) return 0.5 + 2.7 * math.sin(math.pi * t) ^ 0.7 end
local hm = A.taper(c, A.sub(head, 0, 0.79), function(t) return hw(t * 0.79) end)
local tipP = A.shift(A.sub(head, 0.84, 1), 2, 4)
local tm = A.taper(c, tipP, function(t) return hw(0.84 + 0.16 * t) end, 20)
-- handle (behind head)
local hb = A.ao(HP.mask(), {}, 1, -1)
local handM = X.cyl(32, 6, 32, 57, function() return 1.7 end)
local bias = A.ao(handM, { hm }, 1, -1)
A.rod(c, 32, 6, 32, 57, 1.7, A.WOOD, { grain = 5, bias = bias })
-- end grain wedge on top
for x = 31, 33 do c:px(x, 6, A.WOOD[6]) c:px(x, 7, A.WOOD[5]) end
c:px(32, 6, A.WOOD[4]) c:px(32, 7, A.WOOD[3])
-- butt end: paler end grain
for x = 31, 33 do c:px(x, 57, A.WOOD[4]) end
-- head
local idx, n = A.lit(c, hm, A.STEEL, { R = 2.4, wrap = 0.3 })
A.streak(c, hm, idx, A.STEEL, 26, 2)
A.bevel(c, hm, 0, -1, A.STEEL[6])
for x = 27, 37 do if hm:has(x, 14) and hm:has(x, 15) then end end
local sx, sy = A.specAt(hm, n) c:px(sx, sy, A.SPEC)
-- eye ring: darker ring around the handle where it passes through
for y = 8, 13 do c:px(29, y, A.STEEL[2]) c:px(35, y, A.STEEL[2]) end
for x = 30, 34 do c:px(x, 7, A.STEEL[5]) end
for y = 8, 13 do for x = 30, 34 do c:px(x, y, (x == 30 and A.WOOD[5]) or (x == 34 and A.WOOD[2]) or A.WOOD[4]) end end
c:px(31, 9, A.WOOD[6]) c:px(33, 11, A.WOOD[3])
-- the dropped tip
local ti, tn = A.lit(c, tm, A.STEEL, { R = 1.5, wrap = 0.3 })
A.bevel(c, tm, 0, -1, A.STEEL[6])
-- broken faces: bright fresh steel
for _, p in ipairs{ { 48, 13 }, { 48, 14 }, { 48, 15 }, { 48, 16 } } do if hm:has(p[1], p[2]) then c:px(p[1], p[2], A.STEEL[5]) end end
-- crack in left arm (hairline, deep)
c:px(16, 16, A.STEEL[1]) c:px(17, 15, A.STEEL[1]) c:px(17, 17, A.STEEL[1])
-- handle split at the foot
A.gap(c, { { 32, 57 }, { 32, 53 }, { 33, 50 } }, 1)
c:px(31, 52, A.WOOD[6])
-- flying chip
A.chip(c, { { 53, 26 }, { 57, 25 }, { 55, 29 } }, A.STEEL)
c:px(54, 26, A.SPEC)
-- quirk: bandana knot under the head
local knot = c:rect(29, 16, 35, 20)
local ki, kn = A.lit(c, knot, BAND, { R = 1.5 })
for x = 29, 35 do c:px(x, 18, BAND[3]) end
c:px(36, 17, BAND[4]) c:px(36, 18, BAND[3]) c:px(37, 18, BAND[3])
local tail1 = c:poly{ { 36, 18 }, { 43, 21 }, { 42, 24 }, { 36, 20 } }
A.lit(c, tail1, BAND, { R = 1 })
local tail2 = c:poly{ { 36, 19 }, { 40, 26 }, { 38, 27 }, { 35, 21 } }
A.lit(c, tail2, BAND, { R = 1, bias = A.ao(tail2, { tail1 }, 1, -1) })
for _, p in ipairs{ { 30, 17 }, { 33, 19 }, { 39, 21 }, { 38, 24 } } do c:px(p[1], p[2], "#fff4d6") end
-- contact shadow under knot on handle
for x = 31, 33 do c:px(x, 21, A.WOOD[2]) end
A.save(c)
