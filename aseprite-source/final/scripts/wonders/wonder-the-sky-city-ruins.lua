-- wonder-the-sky-city-ruins.lua : stone ruins above a sea of clouds, doorways onto nothing, a staircase into the sky, a loose stone hiding a hoard.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
local HOR = 100
local NP = { gloss = false, rim = false, bounce = false, outline = false }

L.sky(c, "dawn", HOR + 10)
L.stars(c, 10, 14, 3)
c:fill(c:ellipse(60, 70, 12, 12), "#fbe0a8"); c:fill(c:ellipse(60, 70, 8, 8), "#fff1c8") -- low sun behind the clouds
L.cloud(c, 190, 24, 20, "#f0aa98", "#d49ab8"); L.cloud(c, 40, 36, 16, "#d49ab8", "#a48ac0"); L.cloud(c, 110, 22, 12, "#f8c890", "#f0aa98")
-- far peaks
c:part(c:poly({ {0,HOR},{20,76},{34,84},{52,62},{74,HOR} }), GV.ramp("#7a7ab8"), { cres = 6, deep = 9, gloss = false, rim = false, outline = false })
c:fill(c:poly({ {52,62},{46,72},{50,70},{54,74},{58,70},{60,72},{56,64} }), "#f5e8e0")
c:part(c:poly({ {190,HOR},{206,64},{220,74},{232,56},{W,70},{W,HOR} }), GV.ramp("#7a7ab8"), { cres = 6, deep = 9, gloss = false, rim = false, outline = false })
c:fill(c:poly({ {232,56},{226,66},{230,64},{234,68},{238,64},{238,62} }), "#f5e8e0")
-- sea of clouds (back layer)
c:part(c:rect(0, HOR, W - 1, H - 1), GV.ramp("#e8d0d8"), { cres = 6, deep = 10, gloss = false, rim = false, outline = false })
for _, b in ipairs({ {10,102,22,6},{60,106,26,7},{110,100,20,6},{210,104,26,7},{170,108,18,5},{40,112,18,5},{238,100,14,5} }) do
  c:part(c:ellipse(b[1], b[2], b[3], b[4]), GV.ramp("#f4e8ec"), { cres = 3, deep = 4, gloss = false, rim = false, outline = false })
end
-- main peak with terraces
local peak = c:poly({ {74,H},{96,98},{118,72},{140,52},{160,46},{184,58},{206,82},{232,H} })
c:part(peak, GV.ramp("#6a9a3a"), { cres = 8, deep = 14, gloss = false })
-- terrace walls (stone) in tiers
local tiers = { {58, 148, 172}, {70, 132, 186}, {82, 118, 198}, {94, 104, 212}, {106, 92, 224} }
for _, t in ipairs(tiers) do
  local wall = peak:copy():clip(c:rect(t[2], t[1], t[3], t[1] + 5))
  c:fill(wall, "#c9c5bc"); c:fill(wall:copy():clip(c:rect(0, t[1] + 4, W, t[1] + 5)), "#8b8f96")
  c:fill(wall:copy():clip(c:rect(0, t[1], W, t[1])), "#e8e4dc")
  for x = t[2], t[3], 6 do c:px(x, t[1] + 2, "#8b8f96") end
  for x = t[2] + 3, t[3], 6 do c:px(x, t[1] + 4, "#8b8f96") end
end
-- little crop rows on the terraces
for _, t in ipairs(tiers) do for x = t[2] + 4, t[3] - 6, 9 do c:px(x, t[1] + 7, "#a4b86a"); c:px(x + 1, t[1] + 7, "#c8d77a") end end
-- central stairway down the peak
c:part(c:poly({ {112,H-6},{118,106},{122,96},{130,96},{134,106},{140,H-6} }), GV.ramp("#c9c5bc"), { cres = 4, deep = 6, gloss = false, outline = false })
for y = 98, H - 12, 5 do c:fill(c:rect(118 + (y - 98) // 6 * -1, y, 134 + (y - 98) // 6, y), "#8b8f96") end

-- ruins at the summit: gate wall with a trapezoid doorway onto nothing, broken side wall
local function block_wall(x0, y0, x1, y1)
  c:part(c:rect(x0, y0, x1, y1), GV.ramp("#c9c5bc"), { cres = 4, deep = 6, gloss = false })
  for y = y0 + 4, y1 - 1, 5 do c:fill(c:rect(x0 + 1, y, x1 - 1, y), "#a8a8a8") end
  local k = 0
  for y = y0 + 2, y1 - 1, 5 do for x = x0 + 4 + (k % 2) * 4, x1 - 2, 8 do c:px(x, y, "#a8a8a8"); c:px(x, y + 1, "#a8a8a8") end; k = k + 1 end
end
block_wall(140, 36, 180, 56)
-- trapezoid door (sky seen through: dawn colours)
c:fill(c:poly({ {151,56},{154,40},{166,40},{169,56} }), "#f0aa98"); c:fill(c:poly({ {153,56},{155,44},{165,44},{167,56} }), "#f8c890")
c:fill(c:rect(150, 38, 170, 39), "#5b6470"); c:fill(c:rect(150, 38, 170, 38), "#8b8f96")
-- broken side wall and a lone arch (window onto nothing)
block_wall(118, 48, 138, 60)
c:fill(c:poly({ {120,48},{124,44},{128,48},{130,45},{134,48} }), "#c9c5bc")
c:fill(c:rect(124, 52, 127, 58), "#f8c890"); c:fill(c:rect(124, 52, 127, 52), "#5b6470")
block_wall(184, 50, 200, 64)
c:fill(c:rect(190, 54, 193, 62), "#f0aa98")
-- the staircase into the sky: stone steps climbing from the gate, then a gap, then floating steps; one cloud sits on the last
local sx, sy = 172, 36
for k = 0, 9 do
  local x, y = sx + k * 5, sy - k * 3
  c:fill(c:rect(x, y, x + 8, y + 3), "#c9c5bc"); c:fill(c:rect(x, y, x + 8, y), "#f1ece0"); c:fill(c:rect(x + 1, y + 3, x + 8, y + 3), "#8b8f96"); c:fill(c:rect(x + 8, y, x + 8, y + 3), "#8b8f96")
end
c:part(c:ellipse(228, 6, 8, 3), GV.ramp("#f4e8ec"), { flat = true, gloss = false, outline = false })

for _, b in ipairs({ {96,122,20,6},{150,118,16,5},{214,124,22,6},{236,114,10,5},{126,130,14,4} }) do
  c:part(c:ellipse(b[1], b[2], b[3], b[4]), GV.ramp("#f4e8ec"), { cres = 3, deep = 4, gloss = false, rim = false, outline = false })
end
-- foreground ledge with big blocks (wall in front)
local ledge = c:poly({ {0,H},{0,112},{22,106},{58,108},{66,H} })
c:part(ledge, GV.ramp("#c9c5bc"), { cres = 6, deep = 10, gloss = false })
for y = 114, H - 6, 7 do c:fill(ledge:copy():clip(c:rect(0, y, 70, y)), "#8b8f96") end
for k, y in ipairs({ 107, 114, 121 }) do for x = 6 + (k % 2) * 8, 60, 16 do c:px(x, y + 2, "#8b8f96"); c:px(x, y + 3, "#8b8f96") end end
-- moss on ledge
for _, x in ipairs({ 8, 20, 36, 48 }) do c:fill(c:rect(x, 108 - (x > 20 and 1 or -2), x + 4, 109 - (x > 20 and 1 or -2)), "#7ab55c") end

-- llama on the ledge (chibi)
local lx, ly = 30, 106
c:ground(lx, ly + 1, 14, 2, "#8b8f96")
for _, dx in ipairs({ -7, -3, 3, 7 }) do c:part(c:rect(lx + dx - 1, ly - 7, lx + dx, ly), GV.ramp("#e8d9b0"), { flat = true, gloss = false, outline = false, contour = "#4a2c1a" }) end
c:part(c:ellipse(lx, ly - 11, 11, 7), GV.ramp("#e8d9b0"), { cres = 4, deep = 6, pale = true })
c:part(c:rect(lx + 6, ly - 22, lx + 10, ly - 12), GV.ramp("#e8d9b0"), { cres = 2, deep = 3, pale = true })
c:part(c:ellipse(lx + 12, ly - 24, 7, 6), GV.ramp("#e8d9b0"), { cres = 3, deep = 4, pale = true })
c:part(c:rect(lx + 8, ly - 32, lx + 9, ly - 27), GV.ramp("#e8d9b0"), { flat = true, gloss = false, contour = "#4a2c1a" })
c:part(c:rect(lx + 14, ly - 32, lx + 15, ly - 27), GV.ramp("#e8d9b0"), { flat = true, gloss = false, contour = "#4a2c1a" })
c:eye(lx + 8, ly - 26, true); c:eye(lx + 13, ly - 26, true)
c:part(c:rect(lx + 16, ly - 24, lx + 20, ly - 20), GV.ramp("#f2e4c0"), { flat = true, gloss = false, pale = true }); c:px(lx + 19, ly - 23, "#2a1a10")
-- red woven blanket on its back
c:part(c:rect(lx - 6, ly - 17, lx + 3, ly - 11), GV.ramp("#d6322b"), { flat = true, gloss = false })
c:fill(c:rect(lx - 6, ly - 14, lx + 3, ly - 14), "#f5cf6a"); c:px(lx - 3, ly - 16, "#f5cf6a"); c:px(lx, ly - 16, "#f5cf6a")

-- loose stone and the small careful hoard at the right foreground
local rx, ry = 176, 126
c:part(c:poly({ {146,H},{152,112},{W,112},{W,H} }), GV.ramp("#c9c5bc"), { cres = 6, deep = 10, gloss = false })
for y = 120, H - 6, 7 do c:fill(c:rect(152, y, W - 1, y), "#8b8f96") end
for k, y in ipairs({ 113, 120, 127 }) do for x = 156 + (k % 2) * 8, W - 4, 16 do c:px(x, y + 2, "#8b8f96"); c:px(x, y + 3, "#8b8f96") end end
-- the loose stone pushed out, gap shows the hoard
c:fill(c:rect(176, 114, 200, 128), "#2a1a10")
c:fill(c:rect(178, 116, 198, 128), "#5e2f1e"); c:fill(c:rect(180, 120, 196, 128), "#8a4f2a")
c:part(c:ellipse(188, 126, 7, 3), GV.ramp("#e8a317"), { flat = true, gloss = false })
for _, p in ipairs({ {183,122},{187,120},{191,122},{185,124},{190,124} }) do c:fill(c:rect(p[1], p[2], p[1] + 1, p[2]), "#f5cf6a"); c:px(p[1], p[2] - 1, "#fff1c8") end
c:part(c:rect(205, 116, 224, 124), GV.ramp("#c9c5bc"), { cres = 3, deep = 4, gloss = false })
c:px(200, 120, "#fff1c8"); c:px(201, 119, "#f5cf6a"); c:px(174, 118, "#fff1c8")
L.finish(c, "wonder-the-sky-city-ruins")
