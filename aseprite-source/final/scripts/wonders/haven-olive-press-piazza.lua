-- haven-olive-press-piazza : southern-European piazza, golden afternoon. Stone olive press, bread oven, olive-wood tools.
local REPO = "/home/user/gnome-venture/"
local H = dofile(REPO .. "aseprite-source/final/scripts/wonders/h3lib.lua")
local L, GV = H.L, H.GV
local c = L.new()
local W, HT = L.W, L.H

L.sky(c, "warm", 60)
L.cloud(c, 50, 20, 16, "#fff1d8", "#f5cc92"); L.cloud(c, 180, 14, 20, "#fff1d8", "#f5cc92")
-- hills + cypress
c:part(L.below(c, function(x) return 50 + math.sin(x / 30) * 4 end), GV.ramp("#a4b86a"), { cres = 6, deep = 9, gloss = false, outline = false, rim = false })
for _, p in ipairs({ {96,52},{106,50},{168,54} }) do
  c:part(c:ellipse(p[1], p[2], 3, 10), GV.ramp("#2f5a2a"), { cres = 2, deep = 3, gloss = false, outline = false })
end

-- buildings row
local function building(x0, x1, y0, wall, roof, tower)
  c:part(c:rect(x0, y0, x1, 94), GV.ramp(wall), { cres = 5, deep = 8, gloss = false })
  c:part(c:poly({ {x0 - 3, y0 + 1}, {x0 + 4, y0 - 6}, {x1 - 4, y0 - 6}, {x1 + 3, y0 + 1} }), GV.ramp(roof), { cres = 3, deep = 5, gloss = false })
  for x = x0 + 3, x1 - 6, 6 do c:fill(c:rect(x, y0 - 5, x, y0 - 1), "#a8301f") end
end
building(0, 66, 56, "#e8b070", "#d6532b")
building(66, 122, 46, "#f2d49a", "#b8452f")
building(122, 186, 58, "#d9885a", "#d6532b")
building(186, 240, 52, "#f2e4c0", "#b8452f")
-- bell tower on the second building
c:part(c:rect(88, 24, 100, 46), GV.ramp("#f2d49a"), { cres = 3, deep = 5, gloss = false })
c:part(c:rrect(90, 28, 98, 38, 3), GV.ramp("#291d4a"), { flat = true, gloss = false, outline = false, contour = "#2a1a10" })
c:part(c:ellipse(94, 34, 2, 2.5), GV.ramp("#e8a317"), { flat = true, gloss = false, outline = false })
c:part(c:poly({ {86, 25}, {94, 14}, {102, 25} }), GV.ramp("#b8452f"), { cres = 3, deep = 4, gloss = false })
-- windows (arched, shuttered) and doors
local function win(x, y, shut)
  c:part(c:rrect(x, y, x + 6, y + 11, 3), GV.ramp("#291d4a"), { flat = true, gloss = false, outline = false, contour = "#2a1a10" })
  c:part(c:rect(x - 3, y + 2, x - 1, y + 11), GV.ramp(shut), { flat = true, gloss = false, outline = false })
  c:part(c:rect(x + 7, y + 2, x + 9, y + 11), GV.ramp(shut), { flat = true, gloss = false, outline = false })
end
for _, p in ipairs({ {12,66,"#4e8a9a"},{46,66,"#4e8a9a"},{72,56,"#4a8a3e"},{108,58,"#4a8a3e"},{128,68,"#4e8a9a"},{160,68,"#4e8a9a"},{192,64,"#d6322b"},{224,64,"#d6322b"} }) do win(p[1], p[2], p[3]) end
c:part(c:rrect(142, 74, 152, 94, 4), GV.ramp("#5e2f1e"), { cres = 2, deep = 3, gloss = false, outline = false, contour = "#2a1a10" })
c:part(c:rrect(88, 72, 100, 94, 5), GV.ramp("#5e2f1e"), { cres = 2, deep = 3, gloss = false, outline = false, contour = "#2a1a10" })
-- flower pots on sills
for _, x in ipairs({ 14, 48, 194, 226 }) do c:px(x, 77, "#e46a9b"); c:px(x + 2, 76, "#f6b8cf"); c:px(x + 4, 77, "#e46a9b"); c:fill(c:rect(x, 78, x + 4, 79), "#b8452f") end

-- piazza floor
c:part(L.below(c, function(x) return 94 end), GV.ramp("#d9c8a0"), { cres = 6, deep = 10, gloss = false, outline = false, rim = false })
for i = 0, 70 do
  local x = (i * 37 + 5) % W; local y = 97 + (i * 17) % 34
  c:fill(c:rect(x, y, x + 3, y), "#b8a07a"); c:fill(c:rect(x + 1, y + 1, x + 4, y + 1), "#f2e4c0")
end

-- bunting
local cols = { "#d6322b", "#f5cf6a", "#4e8a9a", "#7ab55c" }
local function bunt(xa, ya, xb, yb)
  local n = 9
  for i = 0, n do
    local t = i / n; local x = xa + (xb - xa) * t; local y = ya + (yb - ya) * t + math.sin(t * math.pi) * 6
    c:px(x, y, "#2a1a10"); c:px(x + 1, y, "#2a1a10")
    c:fill(c:poly({ {x - 1, y + 1}, {x + 4, y + 1}, {x + 1.5, y + 7} }), cols[(i % 4) + 1])
  end
end
bunt(0, 40, 90, 22); bunt(100, 22, 240, 36)

-- bread oven (left): clay dome with glowing mouth, chimney
c:part(c:ellipse(30, 94, 22, 18):clip(c:rect(0, 70, 80, 94)), GV.ramp("#d9885a"), { cres = 6, deep = 9, gloss = false })
c:part(c:rect(40, 66, 46, 80), GV.ramp("#8b8f96"), { cres = 2, deep = 3, gloss = false })
c:part(c:rrect(20, 82, 38, 94, 7), GV.ramp("#2a1a10"), { flat = true, gloss = false, outline = false })
c:fill(c:ellipse(29, 90, 5, 4), "#f08a24"); c:fill(c:ellipse(29, 91, 3, 2), "#f5cf6a")
c:px(43, 63, "#c9c5bc"); c:px(44, 60, "#e8e0d0"); c:px(43, 57, "#c9c5bc")
for i = 0, 5 do c:fill(c:rect(10 + i * 3, 78 - i, 10 + i * 3, 79 - i), "#b8452f") end
-- baker's table with loaves
c:part(c:rect(6, 112, 52, 116), GV.ramp("#b07a45"), { cres = 2, deep = 3, gloss = false })
for _, x in ipairs({ 10, 48 }) do c:part(c:rect(x, 116, x + 2, 128), GV.ramp("#8a4f2a"), { flat = true, gloss = false }) end
for i, x in ipairs({ 11, 20, 29, 38, 46 }) do
  c:part(c:ellipse(x + 2, 109, 5, 3.5), GV.ramp(i % 2 == 0 and "#c27a3e" or "#d9a660"), { cres = 2, deep = 3, gloss = false })
  c:seam({ {x - 1, 108}, {x + 4, 108} }, { free = true, on = 1, off = 1, gap = "#8a4f2a" })
end
H.folk(c, 66, 124, { cloth = "#f2e4c0", hat = "#7ab55c", big = true, beard = "#d8c496" })

-- THE PRESS (centre): stone trough, upright millstone, beam, gnome pushing
local px, py = 120, 116
c:part(c:ellipse(px, py, 26, 8), GV.ramp("#8b8f96"), { cres = 4, deep = 7 })
c:part(c:ellipse(px, py - 1, 22, 5), GV.ramp("#4a5a2a"), { flat = true, gloss = false, outline = false, rim = false })
for _, o in ipairs({ {-14,0},{-6,2},{4,-1},{12,1},{-1,3},{16,-2} }) do c:part(c:ellipse(px + o[1], py + o[2] - 1, 2, 1.5), GV.ramp("#4a3a6a"), { flat = true, gloss = false, outline = false }) end
c:part(c:rect(px - 2, 72, px + 2, py), GV.ramp("#8a4f2a"), { cres = 2, deep = 3, gloss = false })       -- central post
c:part(c:ellipse(px + 11, py - 9, 8, 12), GV.ramp("#c9c5bc"), { cres = 4, deep = 7 })                    -- millstone on edge
c:part(c:ellipse(px + 11, py - 9, 2, 3), GV.ramp("#5b6470"), { flat = true, gloss = false, outline = false })
c:part(c:rect(px - 30, 84, px + 36, 88), GV.ramp("#b07a45"), { cres = 2, deep = 3, gloss = false })     -- the sweep beam
c:seam({ {px - 26, 86}, {px + 32, 86} }, { free = true, on = 2, off = 1 })
c:part(c:ellipse(px, 72, 4, 3), GV.ramp("#e8a317"), { flat = true, gloss = false })
-- spout and oil jug
c:part(c:poly({ {px - 26, py - 1}, {px - 33, py + 3}, {px - 26, py + 4} }), GV.ramp("#8b8f96"), { flat = true, gloss = false })
c:fill(c:rect(px - 33, py + 4, px - 33, py + 9), "#f5cf6a")
c:part(c:ellipse(px - 33, py + 13, 6, 7), GV.ramp("#b8452f"), { cres = 3, deep = 5 })
c:part(c:rect(px - 36, py + 4, px - 30, py + 7), GV.ramp("#b8452f"), { cres = 1, deep = 2, gloss = false, outline = false })
c:fill(c:rect(px - 34, py + 4, px - 32, py + 5), "#f5cf6a")
-- gnome leaning on the beam
H.folk(c, px + 40, 112, { cloth = "#4e8a9a", hat = "#d6322b", lean = 3, big = true })
c:part(c:line({ {px + 34, 99}, {px + 33, 90} }, 2), GV.ramp("#e9b98a"), { flat = true, gloss = false, outline = false })

-- olive tree (right) and crates
c:part(c:poly({ {198,96},{200,70},{207,64},{208,96} }), GV.ramp("#8a6a4a"), { cres = 2, deep = 4, gloss = false })
for _, p in ipairs({ {204,52,17,11},{190,60,10,8},{220,58,12,9} }) do c:part(c:ellipse(p[1], p[2], p[3], p[4]), GV.ramp("#8a9a6a"), { cres = 4, deep = 7, gloss = false }) end
for _, p in ipairs({ {198,50},{206,56},{212,48},{190,60},{222,60},{204,44},{216,56} }) do c:fill(c:rect(p[1], p[2], p[1] + 1, p[2] + 1), "#2f2a4a") end
c:part(c:rrect(180, 112, 200, 124, 1), GV.ramp("#b07a45"), { cres = 3, deep = 4, gloss = false })
for _, x in ipairs({ 184, 190, 196 }) do c:part(c:ellipse(x, 111, 3, 2.5), GV.ramp(x == 190 and "#4a5a2a" or "#2f2a4a"), { flat = true, gloss = false, outline = false }) end
c:seam({ {182, 118}, {198, 118} }, { on = 2, off = 1 })
-- olive-wood tools table: spoons, bowl, board
c:part(c:rect(206, 112, 238, 115), GV.ramp("#d9a660"), { cres = 2, deep = 3, gloss = false })
c:part(c:rect(208, 115, 210, 126), GV.ramp("#8a4f2a"), { flat = true, gloss = false }); c:part(c:rect(234, 115, 236, 126), GV.ramp("#8a4f2a"), { flat = true, gloss = false })
c:part(c:ellipse(214, 108, 4, 3), GV.ramp("#b07a45"), { flat = true, gloss = false })
for i, x in ipairs({ 222, 227, 232 }) do
  c:part(c:line({ {x, 99 + i}, {x, 111} }, 2), GV.ramp("#b07a45"), { flat = true, gloss = false, outline = false })
  c:part(c:ellipse(x, 98 + i, 2, 3), GV.ramp("#d9a660"), { flat = true, gloss = false, outline = false })
end
H.folk(c, 214, 128, { cloth = "#6a4fa8", hat = "#e8a317", big = true })
-- oil jugs in front
for _, x in ipairs({ 164, 172 }) do
  c:part(c:ellipse(x, 124, 5, 6), GV.ramp("#d9885a"), { cres = 3, deep = 5 })
  c:part(c:rect(x - 2, 115, x + 1, 118), GV.ramp("#d9885a"), { flat = true, gloss = false })
end
L.finish(c, "haven-olive-press-piazza")
