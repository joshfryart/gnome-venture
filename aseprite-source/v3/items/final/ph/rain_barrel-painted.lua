-- rain_barrel-painted (Opus single pass, final). A tall slim rain barrel whose staves are hand-painted in two
-- alternating blues, banded with yellow-painted hoops, a daisy with stem and leaves painted on the front and a few
-- paint drips; staves are lit per pixel (curved body, seams, grain flecks), the rim is wood with a water surface
-- inside, a stone downpipe with a bracket pours a drip stream into it, and a brass tap sits low on the left.
-- quirk: a little yellow rubber duck is bobbing in the water.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD11_3.lua")
local G, D, X, HP, K = A.G, A.D, A.X, A.HP, A.K
local floor, max, min, abs = math.floor, math.max, math.min, math.abs
local c = G.new2("rain_barrel-painted")
local R = A.ramp
local BL1, BL2 = R("#2686c0"), R("#3566c4")
c:groundShadow(33, 56, 15, 2)
local CX, YT, YB = 34, 22, 52
-- pipe first (behind): vertical down the left, across over the barrel, spout
D.pipe(c, 10, 9, 13, 25, 3, "stone")
local b = D.barrel(c, { cx = CX, yt = YT, yb = YB, wt = 12, wb = 11, bulge = 3, ry = 4.6, wood = "#3566c4",
  staveRamp = function(k) return (k % 2 == 0) and BL1 or BL2 end, hoops = { YT + 7, YB - 8 }, hoop = "#f0b830", nst = 7,
  water = "sea", lv = 2 })
-- re-draw the pipe spout over the rim back (it is in front of the back rim)
D.pipe(c, 10, 9, 13, 25, 3, "stone")
-- drip stream
c:px(25, 17, "#b6f0e0") c:px(25, 19, "#b6f0e0") c:px(25, 20, "#5fc4c8")
c:px(24, 23, "#e4f6ff") c:px(25, 23, "#e4f6ff") c:px(26, 23, "#b6f0e0")
-- painted daisy on the front
local dx, dy = CX - 1, 35
local PET, PETS, GOLD, GOLDS = "#fff4d6", "#d8c3a8", "#f5b82e", "#d98322"
for _, p in ipairs{ { 0, -3 }, { 0, 3 }, { -3, 0 }, { 3, 0 }, { -2, -2 }, { 2, -2 }, { -2, 2 }, { 2, 2 } } do
  c:px(dx + p[1], dy + p[2], (p[1] >= 0 and p[2] >= 0) and PETS or PET)
  c:px(dx + p[1] // 2 * 0 + (p[1] > 0 and 1 or (p[1] < 0 and -1 or 0)) * 2 // 2 * 1 * 0 + p[1] * 0, dy + p[2], (p[1] >= 0 and p[2] >= 0) and PETS or PET)
end
for yy = -1, 1 do for xx = -1, 1 do c:px(dx + xx, dy + yy, (xx + yy > 0) and GOLDS or GOLD) end end
c:px(dx - 1, dy - 1, "#ffe38a")
-- stem + leaves
for yy = 4, 9 do c:px(dx, dy + yy, "#3f9150") end
c:px(dx - 1, dy + 6, "#7cc35a") c:px(dx - 2, dy + 5, "#7cc35a") c:px(dx - 1, dy + 5, "#3f9150")
c:px(dx + 1, dy + 7, "#7cc35a") c:px(dx + 2, dy + 6, "#7cc35a") c:px(dx + 1, dy + 6, "#3f9150")
-- paint drips from the upper hoop
for _, p in ipairs{ { -8, 0 }, { -8, 1 }, { 6, 0 }, { 6, 1 }, { 6, 2 }, { 11, 0 } } do
  local x, y = CX + p[1], YT + 9 + p[2]
  c:px(x, y, "#f0b830")
end
c:px(CX + 6, YT + 12, "#c98a18")
-- brass tap, low left
local brass = R("#d6a23a")
D.rod(c, 25, 47, 18, 47, 1.5, brass, { amb = .1 })
c:px(19, 45, brass[4]) c:px(19, 44, brass[5]) c:px(20, 45, brass[3])
c:px(17, 50, "#b6f0e0") c:px(17, 51, "#5fc4c8")
-- rubber duck floating (quirk)
local YL = R("#f5c82e")
local dkx, dky = 37, 19
local function d(x, y, i) c:px(dkx + x, dky + y, YL[i]) end
for x = 0, 6 do d(x, 3, x < 2 and 4 or 3) end
for x = 1, 6 do d(x, 2, x < 3 and 5 or 4) end
d(0, 2, 4) d(-1, 1, 5)                     -- tail flick
for x = 4, 6 do d(x, 1, 5) d(x, 0, 5) end
d(5, -1, 6) d(4, -1, 5)
c:px(dkx + 7, dky + 1, "#f27a2a") c:px(dkx + 8, dky + 1, "#d9531e")   -- beak
c:px(dkx + 5, dky, "#2b1c26")                                          -- eye
for x = 2, 4 do c:px(dkx + x, dky + 2, YL[2]) end                       -- wing line
c:px(dkx - 1, dky + 4, "#e4f6ff") c:px(dkx, dky + 4, "#b6f0e0") c:px(dkx + 5, dky + 4, "#b6f0e0") c:px(dkx + 6, dky + 4, "#e4f6ff")
G.save2(c, "rain_barrel-painted")
