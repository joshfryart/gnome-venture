-- Player gnome for the slim home page: 32x48, front view, standing, feet bottom-centre (ink at y47), transparent.
-- Hat uses the rig's marker greys (#f0f0f0 #b4b4b4 #787878 #3c3c3c) and the beard a separate cream ramp
-- (#f4ead8 #d4c6ae #a0927e #5e5448), so code can palette-map each (see models/rig/recolor.js). Everything else fixed.
-- quirk: a single acorn button on the belt instead of a buckle.
local SRC = "/home/user/gnome-venture/aseprite-source"
local HP = dofile(SRC .. "/v3/lib/hp.lua")
local OUT = app.params.out or (SRC .. "/v3/hovel/")
local c = HP.canvas{ w = 32, h = 48, scale = 1, name = "gnome-home" }
local floor, max, min, abs = math.floor, math.max, math.min, math.abs
local INK = "#2b1c26"
local HAT = {"#3c3c3c", "#787878", "#b4b4b4", "#f0f0f0"}       -- deep shade base hi
local BRD = {"#5e5448", "#a0927e", "#d4c6ae", "#f4ead8"}
local SKN = {"#7a4036", "#c98462", "#f0b98d", "#ffe0bd"}
local TUN = {"#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0"}
local BOOT = {"#51302b", "#864c33", "#b97a4a", "#e8b982"}
local GLD = {"#8f4a1f", "#d98322", "#f5b82e", "#ffe38a"}
local function P(x, y, col) c:put(x, y, col) end
local function R(x0, y0, x1, y1, col) for y = y0, y1 do for x = x0, x1 do c:put(x, y, col) end end end

-- boots (y 42..46), toes turned out
local function boot(x0, x1, toe)
  R(x0, 42, x1, 46, BOOT[2]); R(x0, 42, x1, 42, BOOT[3])
  P(toe, 45, BOOT[2]); P(toe, 46, BOOT[1]); R(x0, 46, x1, 46, BOOT[1])
  P(x0 + 1, 43, BOOT[4])
end
boot(10, 14, 9); boot(17, 21, 22)
P(15, 42, INK); P(16, 42, INK); P(15, 43, INK); P(16, 43, INK)

-- tunic body (y 27..41) and arms
for y = 27, 41 do
  local half = 7 + floor((y - 27) / 5)
  for x = 16 - half, 15 + half do
    local tone = 3
    if x <= 16 - half + 1 then tone = 4 end
    if x >= 15 + half - 2 then tone = 2 end
    if y == 41 then tone = 1 end
    P(x, y, TUN[tone])
  end
end
for x = 9, 22 do if x % 3 ~= 2 then P(x, 40, GLD[3]) end end                        -- hem stitch
-- belt with an acorn button (quirk)
R(8, 36, 23, 37, BOOT[2]); R(8, 36, 23, 36, BOOT[3]); R(21, 37, 23, 37, BOOT[1])
P(15, 35, "#864c33"); P(16, 35, "#5e3a2e"); P(14, 36, "#b97a4a"); P(15, 36, "#e8b982"); P(16, 36, "#b97a4a"); P(17, 36, "#864c33")
P(15, 37, "#c98a3a"); P(16, 37, "#a8702a"); P(15, 38, "#a8702a"); P(16, 38, "#7a4a1a")
-- arms: sleeves down the sides, hands at y 35..37
for y = 28, 35 do P(6, y, TUN[(y < 31) and 4 or 3]); P(7, y, TUN[3]); P(24, y, TUN[2]); P(25, y, TUN[1 + ((y < 31) and 1 or 0)]) end
for y = 28, 35 do P(8, y, TUN[1]); P(23, y, TUN[1]) end
R(6, 36, 7, 37, SKN[3]); P(6, 36, SKN[4]); R(24, 36, 25, 37, SKN[2]); P(25, 37, SKN[1])

-- head: face y 17..26, ears
R(9, 17, 22, 26, SKN[3])
R(9, 17, 22, 17, SKN[2])                                                             -- hat-brim shade on the brow
R(21, 18, 22, 26, SKN[2])
R(7, 19, 8, 22, SKN[3]); P(7, 19, SKN[4]); P(8, 21, SKN[2]); R(23, 19, 24, 22, SKN[2]); P(24, 22, SKN[1])
-- eyes (2x3 ink pill + cream glint) and cheeks
for _, ex in ipairs{11, 19} do R(ex, 19, ex + 1, 21, INK); P(ex, 19, "#fff4d6") end
P(10, 23, "#f5809f"); P(11, 23, "#f5809f"); P(20, 23, "#f5809f"); P(21, 23, "#f5809f")

-- beard (y 23..35): wide under the cheeks, scalloped lower edge, pointed centre
local scal = {[8] = 31, [9] = 33, [10] = 34, [11] = 33, [12] = 34, [13] = 35, [14] = 36, [15] = 37, [16] = 37, [17] = 36, [18] = 35, [19] = 34, [20] = 33, [21] = 34, [22] = 33, [23] = 31}
for x = 8, 23 do
  local top = (x <= 9 or x >= 22) and 22 or ((x <= 11 or x >= 20) and 24 or 25)
  for y = top, scal[x] do
    local tone = 3
    if x <= 10 then tone = 4 end
    if x >= 20 then tone = 2 end
    if y == scal[x] then tone = 2 end
    if (x == 12 or x == 19) and y > 28 and y < scal[x] then tone = 2 end           -- hair strands
    if x == 15 and y > 29 and y < 36 then tone = 2 end
    if (x == 13 or x == 14) and y == 27 then tone = 4 end
    P(x, y, BRD[tone])
  end
end
-- moustache over the beard (y 24..26), split under the nose
for x = 10, 21 do
  local y = (x <= 11 or x >= 20) and 25 or 24
  P(x, y, BRD[(x < 15) and 4 or 3]); P(x, y + 1, BRD[(x < 15) and 3 or 2]); if x >= 12 and x <= 19 then P(x, 26, BRD[2]) end
end
P(15, 25, BRD[1]); P(16, 25, BRD[1]); P(15, 26, BRD[1]); P(16, 26, BRD[1])
P(9, 22, BRD[1]); P(22, 22, BRD[1])
-- nose: designed, warm, lit tip, dark underside
R(14, 21, 17, 23, "#e09a74"); P(14, 21, "#ffd0aa"); P(15, 21, "#ffe0bd"); R(14, 23, 17, 23, SKN[2]); P(17, 22, SKN[2]); P(13, 23, SKN[1]); P(18, 23, SKN[1])

-- hat (cone y 1..16) with a floppy tip leaning left, brim y 15..17
for y = 4, 16 do
  local half = floor((y - 2) * 10 / 14 + .5)
  local cx = 16 - floor((16 - y) / 6)
  for x = cx - half, cx + half - 1 do
    local rel = (x - (cx - half)) / max(1, 2 * half)
    local tone = 3
    if rel < .28 then tone = 4 end
    if rel > .7 then tone = 2 end
    if y >= 15 then tone = (rel > .7) and 1 or 2 end
    P(x, y, HAT[tone])
  end
end
-- floppy tip: curls over to the left
for _, p in ipairs{{12, 1, 4}, {13, 1, 3}, {11, 2, 4}, {12, 2, 3}, {13, 2, 3}, {14, 2, 2}, {10, 3, 4}, {11, 3, 3}, {12, 3, 3}, {13, 3, 3}, {14, 3, 3}, {15, 3, 2}, {9, 4, 3}, {10, 4, 2}, {9, 5, 2}} do P(p[1], p[2], HAT[p[3]]) end
-- brim band: gold stitch on the band (trim)
for x = 6, 25 do P(x, 13, (x % 3 ~= 2) and GLD[3] or HAT[(x < 18) and 3 or 2]) end
for x = 5, 26 do P(x, 16, HAT[(x < 18) and 2 or 1]) end
for x = 4, 27 do P(x, 17, HAT[1]) end
P(8, 9, HAT[4]); P(9, 9, HAT[4])                                                    -- the hat's pop

c:finish{ outline = true }
HP.assertClean(c)
c:save{ aseprite = OUT .. "gnome-home.aseprite", png = OUT .. "gnome-home.png" }
HP.report(c)
print("ok")
