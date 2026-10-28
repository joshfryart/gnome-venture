-- haven-drum-circle-market : West/Central African village market at night. Drum circle round a fire, groundnut stew on the boil.
local REPO = "/home/user/gnome-venture/"
local H = dofile(REPO .. "aseprite-source/final/scripts/wonders/h3lib.lua")
local L, GV = H.L, H.GV
local c = L.new()
local W, HT = L.W, L.H
local HOR = 84

L.sky(c, "night", HOR)
L.stars(c, 46, 56, 5)
for _, s in ipairs({ {30,14},{90,8},{170,20},{210,10} }) do c:px(s[1]-1, s[2], "#c3b2ea"); c:px(s[1]+1, s[2], "#c3b2ea"); c:px(s[1], s[2]-1, "#c3b2ea"); c:px(s[1], s[2]+1, "#c3b2ea"); c:px(s[1], s[2], "#fff1c8") end
local moon = c:ellipse(40, 28, 8, 8); moon:cut(c:ellipse(44, 25, 7, 7)); c:fill(moon, "#fff1c8")
-- far dark savanna hills
c:part(L.below(c, function(x) return 78 + math.sin(x / 20) * 3 end), GV.ramp("#322c6c"), { cres = 6, deep = 10, gloss = false, outline = false, rim = false })
-- ground, packed earth at night
c:part(L.below(c, function(x) return 88 + math.sin(x / 40) end), GV.ramp("#7a4a1f"), { cres = 6, deep = 10, gloss = false, outline = false, rim = false })
-- firelight pool on the ground (hard rings)
c:fill(c:ellipse(120, 116, 74, 15), "#8a4f2a"); c:fill(c:ellipse(120, 116, 52, 11), "#a8582f"); c:fill(c:ellipse(120, 116, 30, 7), "#c27a3e")

-- baobab, centre back
c:part(c:poly({ {104,94},{110,64},{114,56},{126,56},{130,64},{136,94} }), GV.ramp("#6a4a6a"), { cres = 5, deep = 8, gloss = false })
for _, b in ipairs({ { {112,60},{98,44},{86,38} }, { {120,56},{120,38},{122,26} }, { {128,60},{142,44},{154,36} } }) do
  c:part(c:line(b, 4), GV.ramp("#6a4a6a"), { flat = true, gloss = false })
end
for _, p in ipairs({ {86,36,9,5},{122,24,10,5},{154,34,9,5},{100,42,6,4},{142,42,6,4} }) do c:part(c:ellipse(p[1], p[2], p[3], p[4]), GV.ramp("#3e5a4a"), { cres = 3, deep = 5, gloss = false }) end

-- round huts with conical thatch
local function hut(cx, gy, r, wall)
  c:part(c:rrect(cx - r, gy - 22, cx + r, gy, 3), GV.ramp(wall), { cres = 5, deep = 8, gloss = false })
  c:part(c:poly({ {cx - r - 4, gy - 18}, {cx, gy - 40}, {cx + r + 4, gy - 18} }), GV.ramp("#d9a660"), { cres = 4, deep = 7, gloss = false })
  for i = -2, 2 do c:seam({ {cx + i * 5, gy - 21}, {cx + i * 2, gy - 36} }, { free = true, on = 1, off = 1, gap = "#8a4f2a" }) end
  c:part(c:rrect(cx - 4, gy - 14, cx + 4, gy, 3), GV.ramp("#291d4a"), { flat = true, gloss = false, outline = false, contour = "#2a1a10" })
  c:fill(c:rect(cx - r + 2, gy - 6, cx - r + 5, gy - 5), "#f2e4c0"); c:fill(c:rect(cx + r - 5, gy - 6, cx + r - 2, gy - 5), "#f2e4c0")  -- painted band
end
hut(26, 98, 15, "#a8582f"); hut(216, 96, 14, "#8a4f2a"); hut(72, 90, 11, "#8a4f2a"); hut(172, 90, 11, "#a8582f")
-- strung lanterns between huts
local function lantern(x, y, col) c:fill(c:rect(x, y - 4, x, y - 1), "#2a1a10"); c:part(c:ellipse(x, y + 1, 2, 2.5), GV.ramp(col), { flat = true, gloss = false, outline = false }); c:px(x, y, "#fff1c8") end
for i = 0, 8 do lantern(36 + i * 18, 62 + math.floor(math.sin(i / 8 * math.pi) * 5), (i % 2 == 0) and "#f5cf6a" or "#f08a24") end
c:seam({ {36, 58}, {180, 58} }, { free = true, on = 3, off = 1, gap = "#2a1a10" })

-- the cooking fire with the stew pot on a tripod
local fx, fy = 120, 116
for _, l in ipairs({ { {fx-14,fy-30},{fx,fy-4} }, { {fx+14,fy-30},{fx,fy-4} }, { {fx,fy-30},{fx,fy-4} } }) do c:part(c:line(l, 2), GV.ramp("#5e2f1e"), { flat = true, gloss = false, outline = false }) end
c:part(c:ellipse(fx, fy - 22, 14, 11), GV.ramp("#5b6470"), { cres = 4, deep = 7 })
c:part(c:rect(fx - 14, fy - 30, fx + 14, fy - 28), GV.ramp("#8b8f96"), { flat = true, gloss = false })
c:fill(c:ellipse(fx, fy - 29, 12, 1.5), "#e0a040")
for _, p in ipairs({ {-5,-31},{3,-30},{8,-31} }) do c:px(fx + p[1], fy + p[2], "#f5cf6a") end
for _, p in ipairs({ {-4,-34},{2,-39},{-3,-44} }) do c:fill(c:rect(fx + p[1], fy + p[2], fx + p[1] + 1, fy + p[2] + 1), "#f4f0e0") end
c:part(c:line({ {fx - 11, fy - 4}, {fx + 11, fy - 2} }, 3), GV.ramp("#5e2f1e"), { cres = 1, deep = 2, gloss = false })
c:part(c:poly({ {fx - 9, fy - 3}, {fx - 3, fy - 15}, {fx + 3, fy - 3} }), GV.ramp("#f08a24"), { cres = 2, deep = 3, gloss = false, outline = false })
c:part(c:poly({ {fx + 1, fy - 3}, {fx + 6, fy - 12}, {fx + 11, fy - 3} }), GV.ramp("#e0501f"), { cres = 2, deep = 3, gloss = false, outline = false })
c:fill(c:poly({ {fx - 6, fy - 3}, {fx - 3, fy - 10}, {fx, fy - 3} }), "#f5cf6a")
-- the cook stirring with a long spoon
H.folk(c, 146, 114, { cloth = "#d6322b", hat = "#f5cf6a", big = true, beard = "#f2e4c0" })
c:part(c:line({ {140, 100}, {128, 88} }, 2), GV.ramp("#d9a660"), { flat = true, gloss = false, outline = false })

-- drums
local function drum(x, y, wood)
  y = y + 3
  c:part(c:poly({ {x - 10, y - 14}, {x + 10, y - 14}, {x + 5, y - 6}, {x + 7, y}, {x - 7, y}, {x - 5, y - 6} }), GV.ramp(wood or "#a8582f"), { cres = 3, deep = 5, gloss = false })
  c:seam({ {x - 7, y - 11}, {x - 3, y - 6}, {x + 1, y - 11}, {x + 5, y - 6} }, { free = true, on = 2, off = 0, gap = "#f2e4c0" })
  c:part(c:ellipse(x, y - 14, 10, 3.5), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { flat = true, gloss = false })
  c:part(c:ellipse(x - 5, y - 15, 2.5, 1.5), GV.ramp("#e9b98a"), { flat = true, gloss = false, outline = false })
  c:part(c:ellipse(x + 5, y - 15, 2.5, 1.5), GV.ramp("#e9b98a"), { flat = true, gloss = false, outline = false })
end
-- back row drummers + dancer
H.folk(c, 68, 108, { cloth = "#7ab55c", hat = "#f08a24", sit = true }); drum(68, 113)
H.folk(c, 174, 108, { cloth = "#4e8a9a", hat = "#e46a9b", sit = true }); drum(174, 113)
H.folk(c, 96, 102, { cloth = "#e8a317", hat = "#d6322b", lean = -4 })
c:part(c:line({ {91, 94}, {86, 84} }, 2), GV.ramp("#e9b98a"), { flat = true, gloss = false, outline = false }); c:part(c:line({ {101, 94}, {106, 84} }, 2), GV.ramp("#e9b98a"), { flat = true, gloss = false, outline = false })
-- front drummers (big)
H.folk(c, 56, 119, { cloth = "#e46a9b", hat = "#4e8a9a", sit = true, big = true, beard = "#f2e4c0" }); drum(56, 124, "#8a4f2a")
H.folk(c, 186, 119, { cloth = "#6a4fa8", hat = "#f5cf6a", sit = true, big = true }); drum(186, 124, "#8a4f2a")
-- talking drum (hourglass) in the middle front
H.folk(c, 92, 124, { cloth = "#d6322b", hat = "#7ab55c", sit = true }); 
c:part(c:poly({ {85, 118}, {99, 118}, {95, 124}, {99, 130}, {85, 130}, {89, 124} }), GV.ramp("#d9a660"), { cres = 2, deep = 4, gloss = false })
c:seam({ {87, 120}, {91, 128}, {95, 120}, {97, 128} }, { free = true, on = 2, off = 0, gap = "#8a4f2a" })
-- market mats with groundnuts and calabash bowls (far right and left bottoms)
c:part(c:ellipse(212, 120, 20, 7), GV.ramp("#d6322b"), { cres = 3, deep = 5, gloss = false, rim = false })
c:seam({ {198, 120}, {226, 120} }, { free = true, on = 2, off = 1, gap = "#f5cf6a" })
for _, x in ipairs({ 204, 214, 223 }) do
  c:part(c:ellipse(x, 117, 5, 4), GV.ramp("#d9a660"), { cres = 2, deep = 3, gloss = false })
  for dx = -2, 2, 2 do c:fill(c:rect(x + dx, 113, x + dx + 1, 114), "#e9b98a") end
end
c:part(c:ellipse(28, 122, 22, 7), GV.ramp("#4e8a9a"), { cres = 3, deep = 5, gloss = false, rim = false })
c:seam({ {12, 122}, {44, 122} }, { free = true, on = 2, off = 1, gap = "#f5cf6a" })
for _, x in ipairs({ 14, 26, 38 }) do
  c:part(c:ellipse(x, 119, 5, 3.5), GV.ramp("#b07a45"), { cres = 2, deep = 3, gloss = false })
  c:fill(c:ellipse(x, 117, 3, 1), "#e9b98a")
end
c:fill(c:rect(8, 128, 10, 128), "#f5cf6a")
-- sparks rising from the fire
for _, p in ipairs({ {112,66},{128,60},{118,54},{134,70},{108,76} }) do c:px(p[1], p[2], "#f5cf6a") end
L.finish(c, "haven-drum-circle-market")
