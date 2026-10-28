-- haven-cherry-blossom-teahouse : East Asian hilltop teahouse at dawn, sakura in bloom, mist over the valley.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
local HOR = 78
local RED = "#d6322b"
local PINK, PINKL, PINKD = "#e9a0c0", "#f6c8da", "#c8709c"

local function blossoms(cx, cy, rx, ry, seed)
  local m = c:ellipse(cx, cy, rx, ry)
  m:add(c:ellipse(cx - rx * 0.6, cy + ry * 0.3, rx * 0.5, ry * 0.6)); m:add(c:ellipse(cx + rx * 0.6, cy + ry * 0.25, rx * 0.5, ry * 0.6))
  m:add(c:ellipse(cx - rx * 0.2, cy - ry * 0.6, rx * 0.55, ry * 0.5)); m:add(c:ellipse(cx + rx * 0.3, cy - ry * 0.5, rx * 0.5, ry * 0.5))
  c:part(m, GV.ramp(PINK, { gloss = PINKL, rim = PINKL, shade = PINKD, deep = "#8a4a78" }), { cres = 6, deep = 9, gloss = false })
  local s = seed
  for i = 1, 26 do
    s = (s * 1103515245 + 12345) % 2147483648; local x = cx - rx + s % (2 * rx)
    s = (s * 1103515245 + 12345) % 2147483648; local y = cy - ry + s % (2 * ry)
    if m:has(x, y) then c:px(x, y, (i % 3 == 0) and "#fff1f4" or PINKL); c:px(x + 1, y, PINKL); if i % 4 == 0 then c:px(x, y + 1, PINKD) end end
  end
end
local function gnome(x, y, hat, shirt)
  c:part(c:ellipse(x, y - 5, 6, 6), GV.ramp(shirt), { cres = 3, deep = 4, gloss = false })
  c:part(c:ellipse(x, y - 14, 6, 5.5), "skin", { cres = 3, deep = 4, gloss = false })
  c:part(c:poly({ {x - 7, y - 19}, {x + 1, y - 34}, {x + 7, y - 19} }), GV.ramp(hat), { cres = 3, deep = 4, gloss = false })
  c:eye(x - 5, y - 17, true); c:eye(x + 2, y - 17, true)
  c:fill(c:rect(x - 4, y - 11, x + 4, y - 8), "#f2e4c0")
  c:px(x - 1, y - 13, "#d9885a"); c:px(x, y - 13, "#d9885a")
end

-- dawn sky, sun, mountain -------------------------------------------------------------------------------------------------
L.sky(c, "dawn", HOR)
c:part(c:ellipse(150, 70, 12, 12):clip(c:rect(0, 0, W, 72)), GV.ramp("#fbe0a8"), { flat = true, gloss = false, rim = false, outline = false })
L.cloud(c, 40, 30, 16, "#f8c890", "#f0aa98"); L.cloud(c, 200, 22, 18, "#d49ab8", "#f0aa98"); L.cloud(c, 110, 44, 12, "#fbe0a8", "#f8c890")
-- Fuji-like peak
c:part(c:poly({ {40,HOR+2},{88,40},{98,30},{108,30},{118,40},{170,HOR+2} }), GV.ramp("#7a7ab8", { shade = "#5a6aa8", deep = "#3e4a88" }), { cres = 6, deep = 9, gloss = false, rim = false, outline = false })
c:part(c:poly({ {98,30},{108,30},{118,40},{112,38},{108,44},{102,38},{96,44},{88,40} }), GV.ramp("#f8f0f0", { shade = "#d8c0d4", deep = "#b8a0c8" }), { cres = 3, gloss = false, rim = false, outline = false })
-- far ridges
c:part(c:poly({ {0,HOR+2},{0,62},{30,58},{50,66},{60,HOR+2} }), GV.ramp("#8a7ab8"), { cres = 4, gloss = false, rim = false, outline = false })
c:part(c:poly({ {160,HOR+2},{185,64},{215,56},{240,60},{240,HOR+2} }), GV.ramp("#8a7ab8"), { cres = 4, gloss = false, rim = false, outline = false })
-- valley below: patchwork fields and mist bands
c:part(c:rect(0, HOR + 1, W - 1, 100), GV.ramp("#a4b86a"), { cres = 4, gloss = false, rim = false, outline = false })
for i, p in ipairs({ {10,84,30},{50,88,26},{90,82,34},{136,86,28},{176,84,30},{210,90,26},{30,94,40},{110,94,38},{170,94,36} }) do
  c:fill(c:rect(p[1], p[2], p[1] + p[3], p[2] + 3), (i % 2 == 0) and "#7ab55c" or "#c8d77a")
end
-- tiny pagoda in the valley
c:part(c:rect(124, 70, 130, 84), GV.ramp("#a8582f"), { cres = 2, gloss = false })
for i = 0, 2 do c:part(c:poly({ {120,74 + i * 5 - 4},{127,70 + i * 5 - 4},{134,74 + i * 5 - 4},{127,76 + i * 5 - 4} }), GV.ramp("#3e2f66"), { cres = 2, gloss = false, outline = false }) end
-- mist
c:fill(c:ellipse(60, 82, 40, 3), "#fbe0a8"); c:fill(c:ellipse(170, 86, 44, 3), "#f8c890"); c:fill(c:ellipse(100, 92, 50, 2), "#fbe0a8"); c:fill(c:ellipse(210, 80, 24, 2), "#fbe0a8")
-- river ribbon
c:fill(c:poly({ {30,100},{46,96},{70,92},{110,90},{150,94},{186,98},{200,100},{190,101},{150,98},{110,95},{70,97},{46,101} }), "#8fcbd8")

-- hilltop foreground ---------------------------------------------------------------------------------------------------------------
c:part(c:poly({ {0,H},{0,102},{40,100},{110,106},{170,102},{W,96},{W,H} }), GV.ramp("#7ab55c"), { cres = 5, deep = 8, gloss = false, rim = false })
for _, x in ipairs({ 14, 60, 100, 140, 18, 80 }) do c:px(x, 112 + (x % 7), "#a4b86a"); c:px(x + 1, 111 + (x % 7), "#c8d77a") end
-- stone steps / path to the teahouse
for i = 0, 4 do c:part(c:rrect(86 + i * 3, 124 - i * 4, 110 + i * 3, 126 - i * 4, 1), GV.ramp("#c9c5bc"), { cres = 1, gloss = false, outline = false, contour = "#74462a" }) end

-- the teahouse ------------------------------------------------------------------------------------------------------------------------
local X0, X1 = 130, 226
c:part(c:rect(X0 - 4, 106, X1 + 4, 112), GV.ramp("#b07a45"), { cres = 3, deep = 4, gloss = false })          -- deck
for x = X0, X1, 10 do c:fill(c:rect(x, 108, x, 111), "#8a4f2a") end
c:part(c:rect(X0, 72, X1, 106), GV.ramp("#f2e4c0", { dot = "#fff3c8", gloss = "#fff3c8" }), { cres = 5, deep = 8, pale = true, gloss = false })
-- shoji screens
for i = 0, 3 do
  local sx = X0 + 6 + i * 22
  c:part(c:rect(sx, 78, sx + 18, 104), GV.ramp(i == 1 and "#f5cf6a" or "#fbf0d0"), { cres = 2, gloss = false, outline = false, contour = "#74462a" })
  c:fill(c:rect(sx + 9, 78, sx + 9, 104), "#8a4f2a"); c:fill(c:rect(sx, 91, sx + 18, 91), "#8a4f2a"); c:fill(c:rect(sx, 85, sx + 18, 85), "#a8582f")
end
-- posts
for _, x in ipairs({ X0, X0 + 44, X1 - 2 }) do c:part(c:rect(x, 74, x + 3, 106), GV.ramp("#a8582f"), { cres = 2, gloss = false }) end
-- curved roof with upturned eaves (two tiers)
c:part(c:poly({ {X0 - 14,76},{X0 - 6,72},{X0,62},{X1,62},{X1 + 6,72},{X1 + 14,76},{X1 + 4,76},{X1 - 6,74},{X0 + 6,74},{X0 - 4,76} }), GV.ramp("#3e2f66", { rim = "#7b66b4", shade = "#291d4a", deep = "#1c1236" }), { cres = 4, deep = 6, gloss = false })
c:part(c:poly({ {X0 + 8,62},{X0 + 18,48},{X1 - 18,48},{X1 - 8,62} }), GV.ramp("#3e2f66", { rim = "#7b66b4", shade = "#291d4a", deep = "#1c1236" }), { cres = 4, deep = 6, gloss = false })
for x = X0 + 4, X1 - 4, 8 do c:seam({ {x, 64}, {x - 1, 70} }, { free = true, on = 1, off = 0, gap = "#54447f" }) end
c:part(c:rect(X0 + 20, 44, X1 - 20, 48), GV.ramp("#3e2f66"), { cres = 2, gloss = false })
c:part(c:ellipse((X0 + X1) // 2, 42, 3, 3), GV.ramp("#e8a317"), { flat = true })
-- hanging red paper lanterns
for _, x in ipairs({ X0 + 4, X0 + 40, X0 + 70, X1 - 6 }) do
  c:fill(c:rect(x, 76, x, 79), "#4a2c1a")
  c:part(c:ellipse(x, 84, 4, 5), GV.ramp(RED), { cres = 2, deep = 3, gloss = false })
  c:fill(c:rect(x - 1, 83, x + 1, 83), "#f5cf6a")
end
-- low tea table on the deck with a pot and cups, gnome sitting
c:part(c:rrect(158, 98, 190, 105, 2), GV.ramp("#8a4f2a"), { cres = 2, deep = 3, gloss = false })
c:part(c:ellipse(170, 94, 5, 4), GV.ramp("#4e8a9a", { rim = "#8fcbd8" }), { cres = 2, deep = 3, gloss = false })
c:fill(c:rect(175, 92, 180, 93), "#4e8a9a"); c:fill(c:rect(165, 88, 175, 89), "#4e8a9a")
for _, x in ipairs({ 180, 185 }) do c:part(c:rect(x, 95, x + 3, 98), GV.ramp("#f2e4c0"), { flat = true, gloss = false, outline = false, contour = "#74462a" }) end
c:px(171, 83, "#e8e4e0")
gnome(206, 108, "#f08a24", "#3f8fb0")
-- teacup raised
c:limb({ {198, 103}, {193, 99}, {190, 96} }, 3)
c:part(c:rect(187, 94, 191, 97), GV.ramp("#f2e4c0"), { flat = true, gloss = false, outline = false, contour = "#74462a" })

-- sakura tree, left foreground ----------------------------------------------------------------------------------------------------------------------
c:part(c:poly({ {26,H},{30,104},{34,86},{40,70},{44,72},{40,90},{42,106},{48,H} }), GV.ramp("#5e2f1e", { rim = "#8a4f2a", shade = "#3d2a1c", deep = "#2a1a10" }), { cres = 3, deep = 4, gloss = false })
c:limb({ {40, 80}, {58, 72}, {72, 66} }, 3); c:limb({ {36, 84}, {22, 76}, {10, 70} }, 3)
blossoms(34, 52, 28, 22, 3)
blossoms(64, 62, 20, 14, 9)
blossoms(12, 62, 14, 12, 5)
-- second tree behind the teahouse
c:part(c:poly({ {226,H},{228,100},{230,80},{234,60},{238,62},{236,84},{238,100},{240,H} }), GV.ramp("#5e2f1e"), { cres = 2, gloss = false })
blossoms(224, 56, 20, 16, 17)
-- falling petals
for _, p in ipairs({ {80,56},{96,70},{112,60},{70,88},{120,100},{150,88},{100,120},{60,110},{140,70},{190,70},{200,40},{172,120},{84,84},{20,96} }) do
  c:px(p[1], p[2], PINKL); c:px(p[1] + 1, p[2] + 1, PINK)
end
-- a calm koi pond with lily pad, foreground bottom-middle-left
c:part(c:ellipse(98, 124, 20, 6), GV.ramp("#3f8fb0"), { cres = 3, deep = 5, gloss = false })
c:fill(c:ellipse(90, 124, 3, 1.5), "#f08a24"); c:px(93, 124, "#f6f0e0"); c:fill(c:ellipse(104, 126, 3, 1), "#f6c8da"); c:fill(c:rect(98, 122, 100, 123), "#7ab55c")

L.finish(c, "haven-cherry-blossom-teahouse")
