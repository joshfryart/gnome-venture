-- haven-driftwood-tavern : Caribbean beach bar at sunset. Coconut water, steel-pan music, shell charms.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
local HOR = 66
local RED = "#d6322b"

local function gnome(x, y, hat, shirt)
  c:part(c:ellipse(x, y - 5, 6, 6), GV.ramp(shirt), { cres = 3, deep = 4, gloss = false })
  c:part(c:ellipse(x, y - 14, 6, 5.5), "skin", { cres = 3, deep = 4, gloss = false })
  c:part(c:poly({ {x - 7, y - 19}, {x + 1, y - 34}, {x + 7, y - 19} }), GV.ramp(hat), { cres = 3, deep = 4, gloss = false })
  c:eye(x - 5, y - 17, true); c:eye(x + 2, y - 17, true)
  c:fill(c:rect(x - 4, y - 11, x + 4, y - 8), "#f2e4c0")
  c:px(x - 1, y - 13, "#d9885a"); c:px(x, y - 13, "#d9885a")
end
local function frond(x, y, dx, dy, col)
  local mx, my = x + dx * 0.55, y + dy * 0.35 - 3
  c:part(c:poly({ {x, y - 2}, {mx, my - 2}, {x + dx, y + dy}, {mx + 1, my + 5}, {x, y + 2} }), GV.ramp(col or "#4a8a3e"), { cres = 2, deep = 3, gloss = false })
end
local function palm(x, y, h, lean)
  local pts = {}
  for i = 0, 5 do pts[#pts + 1] = { x + lean * (i / 5) ^ 2, y - h * i / 5 } end
  c:part(c:poly({ {x - 3, y}, {x + 3, y}, {x + lean + 2, y - h}, {x + lean - 2, y - h} }), GV.ramp("#a8582f"), { cres = 3, deep = 4, gloss = false })
  for i = 1, 4 do c:fill(c:rect(x + math.floor(lean * (i/5)^2) - 2, y - h * i / 5, x + math.floor(lean * (i/5)^2) + 2, y - h * i / 5), "#8a4f2a") end
  local tx, ty = x + lean, y - h
  frond(tx, ty, -22, 4); frond(tx, ty, 22, 4); frond(tx, ty, -14, -10, "#6a9a3a"); frond(tx, ty, 14, -10, "#6a9a3a"); frond(tx, ty, 0, -14, "#7ab55c")
  frond(tx, ty, -18, 14, "#2f5a2a"); frond(tx, ty, 18, 14, "#2f5a2a")
  c:part(c:ellipse(tx - 2, ty + 3, 2.5, 2.5), GV.ramp("#7a4a1f"), { flat = true, gloss = false })
  c:part(c:ellipse(tx + 3, ty + 4, 2.5, 2.5), GV.ramp("#7a4a1f"), { flat = true, gloss = false })
end

-- sky, sun, sea ----------------------------------------------------------------------------------
L.sky(c, "dusk", HOR)
L.stars(c, 14, 22, 5)
c:part(c:ellipse(150, HOR, 12, 12):clip(c:rect(0, 0, W, HOR)), GV.ramp("#f5b878"), { flat = true, gloss = false, rim = false, outline = false })
L.cloud(c, 60, 44, 16, "#8c6ab8", "#b784b4"); L.cloud(c, 190, 32, 14, "#b784b4", "#e39a86"); L.cloud(c, 110, 54, 12, "#e39a86", "#f5b878")
c:bands(c:rect(0, HOR + 1, W - 1, 96), L.SEA.dusk, { dir = "v" })
for i, x in ipairs({ 130, 140, 150, 160, 170, 136, 156 }) do c:fill(c:rect(x, HOR + 2 + (i % 5) * 4, x + 8 - (i % 3) * 2, HOR + 2 + (i % 5) * 4), "#f5b878") end
for i = 0, 8 do local x = (i * 29 + 7) % 200; local y = HOR + 4 + (i * 5) % 26; c:fill(c:rect(x, y, x + 6, y), "#5a86b8") end
-- little sailboat on the horizon
c:part(c:poly({ {96,HOR-1},{108,HOR-1},{105,HOR+3},{99,HOR+3} }), GV.ramp("#7a4a1f"), { flat = true, gloss = false })
c:part(c:poly({ {101,HOR-13},{101,HOR-2},{109,HOR-2} }), GV.ramp("#f2e4c0"), { flat = true, gloss = false })

-- sand ---------------------------------------------------------------------------------------------
c:part(c:poly({ {0,H},{0,92},{60,88},{140,92},{W,86},{W,H} }), GV.ramp("#f1ece0"), { cres = 5, deep = 8, gloss = false, rim = false, outline = false })
c:part(c:poly({ {0,H},{0,112},{70,106},{150,110},{W,104},{W,H} }), GV.ramp("#e6cf9a"), { cres = 5, deep = 8, gloss = false, rim = false, outline = false })
c:fill(c:rect(0, 92, 150, 92), "#cfe8f0")   -- foam line

-- background palm, left
palm(30, 100, 54, -8)

-- the tavern (right): driftwood planks, thatch ----------------------------------------------------------
c:part(c:rect(138, 60, 216, 100), GV.ramp("#d9a660"), { cres = 5, deep = 8, gloss = false })
local pl = { "#b07a45", "#d9a660", "#a8582f", "#c9a96e" }
for i, x in ipairs({ 142, 150, 158, 166, 174, 182, 190, 198, 206, 212 }) do
  c:fill(c:rect(x, 62 + (i % 3), x + 1, 98), pl[(i % 4) + 1])
end
c:seam({ {140, 78}, {214, 78} }, { free = true, on = 3, off = 2, gap = "#8a4f2a" })
-- open bar front (lit interior)
c:part(c:rect(152, 66, 200, 92), GV.ramp("#5e2f1e"), { cres = 2, gloss = false, outline = false, contour = "#2a1a10" })
c:fill(c:rect(154, 68, 198, 90), "#f08a24"); c:fill(c:rect(154, 68, 198, 72), "#f5cf6a"); c:fill(c:rect(154, 86, 198, 90), "#d0862a")
for _, x in ipairs({ 160, 172, 186 }) do   -- shelf bottles
  c:fill(c:rect(x, 76, x + 2, 82), "#3f8fb0"); c:px(x, 76, "#c8ecdc"); c:fill(c:rect(x + 6, 78, x + 8, 82), "#4a8a3e"); c:px(x + 6, 78, "#c8d77a")
end
c:fill(c:rect(154, 83, 198, 83), "#8a4f2a")
-- thatch roof
c:part(c:poly({ {130,64},{140,44},{176,36},{214,44},{224,64} }), GV.ramp("#d9a660", { shade = "#a8582f", deep = "#8a4f2a" }), { cres = 5, deep = 8, gloss = false })
for x = 138, 218, 5 do c:fill(c:rect(x, 48 + (x % 3), x, 60 + (x % 4)), "#b07a45") end
c:fill(c:rect(132, 63, 222, 64), "#a8582f")
-- bar counter
c:part(c:rect(146, 90, 208, 102), GV.ramp("#b07a45"), { cres = 3, deep = 5, gloss = false })
c:seam({ {148, 96}, {206, 96} }, { on = 2, off = 1 })
-- bartender
gnome(174, 92, "#f5cf6a", "#3f8fb0")
c:part(c:ellipse(184, 92, 4, 5), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { cres = 2, gloss = false })
-- counter coconuts with straws
for _, x in ipairs({ 150, 158, 194, 202 }) do
  c:part(c:ellipse(x, 88, 4, 4), GV.ramp("#7a4a1f"), { cres = 2, deep = 3, gloss = false })
  c:fill(c:rect(x - 2, 84, x + 1, 85), "#f2e4c0")
  c:px(x + 2, 82, RED); c:px(x + 3, 80, RED); c:px(x + 3, 81, "#f2e4c0"); c:px(x + 2, 83, "#f2e4c0")
end
-- shell charm strings hanging from the eave
for _, x in ipairs({ 144, 156, 168, 180, 192, 204 }) do
  c:fill(c:rect(x, 65, x, 69 + (x % 3)), "#f5cf6a")
  c:part(c:ellipse(x, 71 + (x % 3), 2, 2), GV.ramp(({ "#f6b8cf", "#f2e4c0", "#8fcbd8" })[(x // 12) % 3 + 1]), { flat = true, gloss = false, outline = false })
end
-- shell sign above
c:part(c:ellipse(177, 54, 8, 7):clip(c:rect(0, 40, W, 61)), GV.ramp("#f6b8cf", { dot = "#fff3c8" }), { cres = 3, deep = 5, gloss = false })
for _, p in ipairs({ {-4,-2},{0,-3},{4,-2} }) do c:seam({ {177, 60}, {177 + p[1] * 2, 54 + p[2] * 3} }, { free = true, on = 1, off = 0, gap = "#d9885a" }) end
-- hanging string lights
for i = 0, 22 do
  local x = 110 + i * 4.6; local y = 50 + math.floor(10 * math.sin(i / 22 * 3.14))
  c:px(x, y, "#4a2c1a")
  if i % 2 == 0 then c:fill(c:rect(x, y + 1, x + 1, y + 2), ({ "#f5cf6a", "#ff9158", "#c8ecdc" })[(i // 2) % 3 + 1]) end
end

-- tiki torch + driftwood stool/barrel with steel pan, musician ----------------------------------------------------------
c:part(c:rect(112, 74, 114, 108), GV.ramp("#8a4f2a"), { cres = 1, gloss = false, outline = false })
c:part(c:ellipse(113, 70, 4, 5), GV.ramp("#f08a24"), { flat = true, gloss = false }); c:fill(c:ellipse(113, 71, 1.5, 2.5), "#f5cf6a"); c:px(113, 63, "#f08a24")
-- musician gnome on a barrel
local bx = 80
c:part(c:rrect(bx - 10, 100, bx + 10, 124, 3), GV.ramp("#8a4f2a"), { cres = 4, deep = 6, gloss = false })
c:seam({ {bx - 9, 106}, {bx + 9, 106} }, { on = 2, off = 1 }); c:seam({ {bx - 9, 118}, {bx + 9, 118} }, { on = 2, off = 1 })
gnome(bx, 100, "#e46a9b", "#f5cf6a")
-- steel pan on stand in front
c:part(c:rect(bx + 22, 104, bx + 24, 124), GV.ramp("#5b6470"), { cres = 1, gloss = false, outline = false })
c:part(c:ellipse(bx + 23, 102, 13, 5), GV.ramp("#8b8f96"), { cres = 3, deep = 4 })
for _, p in ipairs({ {-6,0},{-2,-1},{3,0},{7,-1},{0,2} }) do c:fill(c:ellipse(bx + 23 + p[1], 102 + p[2], 2, 1), "#c9c5bc") end
-- sticks
c:fill(c:rect(bx + 6, 97, bx + 14, 98), "#ecc58a"); c:fill(c:rect(bx + 14, 98, bx + 18, 99), "#ecc58a")
-- notes in the air
for i, p in ipairs({ {62,80},{54,72},{100,76},{108,84} }) do
  c:fill(c:rect(p[1], p[2], p[1] + 1, p[2] + 4), "#fff1c8"); c:fill(c:rect(p[1] - 2, p[2] + 3, p[1] + 1, p[2] + 5), "#fff1c8"); c:px(p[1] + 2, p[2], "#fff1c8")
end

-- foreground: leaning palm right, driftwood log, shells, a hermit crab ---------------------------------------------------
palm(230, 138, 70, -22)
c:part(c:poly({ {0,128},{0,118},{30,116},{58,120},{70,128} }), GV.ramp("#c9c5bc"), { cres = 3, deep = 4, gloss = false, outline = false })
c:part(c:rrect(8, 118, 56, 128, 4), GV.ramp("#b07a45", { gloss = "#ecc58a" }), { cres = 3, deep = 5, gloss = false })
c:seam({ {12, 122}, {50, 122} }, { free = true, on = 3, off = 2, gap = "#5e2f1e" })
c:part(c:ellipse(52, 123, 2.5, 2.5), GV.ramp("#d9a660"), { flat = true, gloss = false })
-- starfish and shells
c:part(c:poly({ {120,126},{123,124},{126,126},{124,129},{128,131},{122,130},{118,131},{120,128} }), GV.ramp(RED), { flat = true, gloss = false })
c:part(c:ellipse(150, 126, 3, 2.5), GV.ramp("#f6b8cf", { dot = "#fff3c8" }), { flat = true, gloss = false })
c:part(c:ellipse(170, 122, 3, 2.5), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { flat = true, gloss = false })
-- hermit crab in a conch
c:part(c:ellipse(104, 124, 6, 5), GV.ramp("#f6b8cf", { dot = "#fff3c8" }), { cres = 3, deep = 4, gloss = false })
c:seam({ {101, 122}, {106, 125} }, { free = true, on = 1, off = 0, gap = "#d9885a" })
c:part(c:ellipse(96, 128, 4, 3), GV.ramp("#e0501f"), { cres = 2, gloss = false })
c:eye(93, 122, true)

L.finish(c, "haven-driftwood-tavern")
