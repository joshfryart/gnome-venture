-- haven-painted-egg-house : Eastern European folk-art cottage, bright spring day. Painted eggs everywhere; a gnome painter.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
local HOR = 70
local RED, BLUE, CREAM = "#d6322b", "#2f6290", "#f2e4c0"
local EGGS = { {"#d6322b","#f5cf6a"}, {"#3f8fb0","#f2e4c0"}, {"#f5cf6a","#d6322b"}, {"#4a8a3e","#f5cf6a"}, {"#e46a9b","#f2e4c0"}, {"#f08a24","#2f6290"}, {"#c3b2ea","#d6322b"} }

local function egg(x, y, k, s)
  local e = EGGS[(k % #EGGS) + 1]
  s = s or 1
  c:part(c:ellipse(x, y, 3 * s, 4 * s), GV.ramp(e[1]), { flat = true, gloss = false, outline = false, contour = "#4a2c1a" })
  c:fill(c:rect(x - 3 * s + 1, y, x + 3 * s - 1, y), e[2])
  c:px(x, y - 2 * s, e[2]); c:px(x, y + 2 * s, e[2])
  if s > 1 then c:px(x - 2, y - 1, e[2]); c:px(x + 2, y - 1, e[2]); c:px(x - 2, y + 1, e[2]); c:px(x + 2, y + 1, e[2]) end
end
local function gnome(x, y, hat, shirt)
  c:part(c:ellipse(x, y - 5, 6, 6), GV.ramp(shirt), { cres = 3, deep = 4, gloss = false })
  c:part(c:ellipse(x, y - 14, 6, 5.5), "skin", { cres = 3, deep = 4, gloss = false })
  c:part(c:poly({ {x - 7, y - 19}, {x + 1, y - 34}, {x + 7, y - 19} }), GV.ramp(hat), { cres = 3, deep = 4, gloss = false })
  c:eye(x - 5, y - 17, true); c:eye(x + 2, y - 17, true)
  c:fill(c:rect(x - 4, y - 11, x + 4, y - 8), "#f2e4c0")
  c:px(x - 1, y - 13, "#d9885a"); c:px(x, y - 13, "#d9885a")
end
local function birch(x, y0, y1, w, leafy)
  c:part(c:rect(x, y1, x + w, y0), GV.ramp("#f1ece0", { shade = "#c9c5bc", deep = "#8b8f96" }), { cres = 2, deep = 3, gloss = false })
  for yy = y1 + 6, y0 - 4, 9 do c:fill(c:rect(x + 1, yy, x + 1 + (yy % 2), yy), "#2a1a10") end
  local m = c:ellipse(x + w / 2, y1 - 6, 14, 12); m:add(c:ellipse(x - 6, y1 + 2, 9, 8)); m:add(c:ellipse(x + w + 6, y1 + 3, 9, 8))
  c:part(m, GV.ramp(leafy, { shade = "#4a8a3e", deep = "#2f5a2a" }), { cres = 5, deep = 8, gloss = false })
  for i = 0, 8 do local px = x - 12 + (i * 7) % 28; local py = y1 - 14 + (i * 5) % 22; if m:has(px, py) then c:px(px, py, "#c8d77a"); c:px(px + 1, py, "#c8d77a") end end
end

-- sky, hills, onion-dome church on a hill -------------------------------------------------------------------------------------------
L.sky(c, "day", HOR)
L.cloud(c, 40, 20, 16); L.cloud(c, 150, 12, 18); L.cloud(c, 214, 30, 12); L.cloud(c, 100, 36, 10)
c:part(c:poly({ {0,HOR+4},{0,56},{60,48},{110,56},{150,HOR+4} }), GV.ramp("#6a9a3a"), { cres = 5, gloss = false, rim = false, outline = false })
c:part(c:poly({ {120,HOR+4},{170,52},{240,46},{240,HOR+4} }), GV.ramp("#7ab55c"), { cres = 5, gloss = false, rim = false, outline = false })
-- church
c:part(c:rect(190, 36, 204, 54), GV.ramp("#f2e4c0", { dot = "#fff3c8", gloss = "#fff3c8" }), { cres = 3, deep = 5, pale = true, gloss = false })
c:part(c:ellipse(197, 30, 6, 7), GV.ramp("#3f8fb0", { rim = "#8fcbd8" }), { cres = 3, deep = 4, gloss = false })
c:part(c:poly({ {193,27},{197,16},{201,27} }), GV.ramp("#3f8fb0", { rim = "#8fcbd8" }), { cres = 2, gloss = false })
c:fill(c:rect(197, 8, 197, 15), "#e8a317"); c:fill(c:rect(195, 10, 199, 10), "#e8a317")
c:fill(c:rect(195, 41, 199, 46), "#35285c")
-- meadow ------------------------------------------------------------------------------------------------------------------------------------
c:part(c:poly({ {0,H},{0,HOR+2},{240,HOR+2},{240,H} }), GV.ramp("#7ab55c", { gloss = "#c8d77a", rim = "#a4b86a" }), { cres = 6, deep = 9, gloss = false, rim = false, outline = false })
-- ploughed strip lines far
for y = HOR + 6, HOR + 12, 3 do c:fill(c:rect(0, y, 70, y), "#6a9a3a"); c:fill(c:rect(170, y, 240, y), "#6a9a3a") end
birch(8, 100, 44, 4, "#6a9a3a")
birch(226, 104, 40, 4, "#7ab55c")
-- flowers scattered
local fcol = { "#e46a9b", "#f5cf6a", "#fff1c8", "#c3b2ea" }
for i = 0, 30 do local x = (i * 47 + 13) % 236; local y = 96 + (i * 13) % 34
  if not (x > 62 and x < 186 and y < 112) then c:px(x, y, fcol[i % 4 + 1]); c:px(x, y + 1, "#4a8a3e") end end

-- the cottage ------------------------------------------------------------------------------------------------------------------------------------------
local CX0, CX1 = 76, 170
c:part(c:rect(CX0, 78, CX1, 108), GV.ramp("#f2e4c0", { dot = "#fff3c8", gloss = "#fff3c8" }), { cres = 5, deep = 8, pale = true, gloss = false })
c:part(c:rect(CX0, 100, CX1, 108), GV.ramp(BLUE), { cres = 3, deep = 5, gloss = false, outline = false, contour = "#2a1a10" })  -- painted blue skirting
for x = CX0 + 3, CX1 - 2, 8 do c:px(x, 103, "#f2e4c0"); c:px(x + 1, 104, "#f2e4c0"); c:px(x + 2, 103, "#f2e4c0") end
-- painted folk border under the eaves: red/blue flowers
for x = CX0 + 4, CX1 - 6, 10 do
  c:fill(c:rect(x, 81, x + 2, 83), RED); c:px(x + 1, 82, "#f5cf6a"); c:fill(c:rect(x + 4, 82, x + 5, 83), "#4a8a3e"); c:px(x + 6, 81, "#4a8a3e")
end
-- thatched roof, steep
c:part(c:poly({ {CX0 - 10,82},{CX0 + 12,58},{CX0 + 28,44},{CX1 - 28,44},{CX1 - 12,58},{CX1 + 10,82} }), GV.ramp("#e8c070", { gloss = "#fff1c8", rim = "#f5cf6a", shade = "#c98a3a", deep = "#8a4f2a" }), { cres = 6, deep = 10, gloss = false })
for x = CX0 - 4, CX1 + 4, 6 do c:fill(c:rect(x, 56 + (x % 4) * 2 - (x > 120 and 0 or 0), x, 80 - (x % 3)), "#c98a3a") end
c:fill(c:rect(CX0 - 8, 81, CX1 + 8, 82), "#a8582f")
-- painted egg on the gable
c:part(c:ellipse(123, 64, 8, 10), GV.ramp(RED), { cres = 3, deep = 5, gloss = false })
c:fill(c:rect(116, 60, 130, 61), "#f5cf6a"); c:fill(c:rect(116, 66, 130, 67), "#f2e4c0"); c:fill(c:rect(117, 64, 129, 64), "#2f6290")
for x = 118, 128, 3 do c:px(x, 62, "#f5cf6a"); c:px(x, 69, "#f5cf6a") end
-- door and windows with painted shutters
c:part(c:rrect(113, 86, 131, 108, 2), GV.ramp("#d6322b"), { cres = 3, deep = 4, gloss = false })
c:fill(c:rect(119, 90, 125, 100), "#f5cf6a"); c:px(122, 95, "#d6322b"); c:fill(c:rect(121, 93, 123, 93), "#d6322b"); c:fill(c:rect(121, 97, 123, 97), "#d6322b")
c:px(129, 98, "#f5cf6a")
for _, wx in ipairs({ 86, 140 }) do
  c:part(c:rect(wx, 88, wx + 16, 100), GV.ramp(BLUE), { cres = 2, gloss = false })
  c:fill(c:rect(wx + 2, 90, wx + 14, 98), "#f5cf6a"); c:fill(c:rect(wx + 8, 90, wx + 8, 98), "#8a4f2a"); c:fill(c:rect(wx + 2, 94, wx + 14, 94), "#8a4f2a")
  c:part(c:rect(wx - 4, 88, wx - 1, 100), GV.ramp(RED), { cres = 1, gloss = false, outline = false }); c:part(c:rect(wx + 17, 88, wx + 20, 100), GV.ramp(RED), { cres = 1, gloss = false, outline = false })
  c:part(c:rect(wx - 1, 101, wx + 17, 104), GV.ramp("#8a4f2a"), { cres = 1, gloss = false, outline = false })
  for k = 0, 3 do c:fill(c:rect(wx + k * 4, 100 - 0, wx + k * 4 + 1, 101), ({ "#e46a9b", "#f5cf6a", RED, "#c3b2ea" })[k + 1]) end
end

-- egg tree in the yard (left of house): bare branches hung with painted eggs ---------------------------------------------------------------------------------
c:part(c:poly({ {42,118},{44,90},{46,70},{50,70},{50,90},{52,118} }), GV.ramp("#8a4f2a", { rim = "#b07a45" }), { cres = 2, deep = 3, gloss = false })
c:limb({ {46, 74}, {34, 66}, {24, 62} }, 2); c:limb({ {50, 74}, {62, 66}, {70, 60} }, 2); c:limb({ {48, 84}, {34, 84}, {26, 88} }, 2); c:limb({ {50, 86}, {62, 88}, {68, 92} }, 2)
for i, p in ipairs({ {24,68},{36,72},{70,66},{62,74},{26,94},{36,90},{68,98},{60,94},{46,60} }) do
  c:fill(c:rect(p[1], p[2] - 6, p[1], p[2] - 3), "#f5cf6a"); egg(p[1], p[2], i, 1)
end
-- a few buds
for _, p in ipairs({ {30,62},{66,62},{40,70},{58,70} }) do c:px(p[1], p[2], "#f6b8cf"); c:px(p[1] + 1, p[2], "#f6b8cf") end

-- wattle fence with egg-shaped pots, front right ----------------------------------------------------------------------------------------------------------------------
for x = 150, 238, 6 do c:part(c:rect(x, 108, x + 2, 124), GV.ramp("#b07a45"), { cres = 1, gloss = false, outline = false, contour = "#5e2f1e" }) end
c:fill(c:rect(150, 112, 238, 113), "#8a4f2a"); c:fill(c:rect(150, 119, 238, 120), "#8a4f2a")
for i, x in ipairs({ 156, 168, 180, 192, 204, 216, 228 }) do egg(x, 106, i + 2, 1) end
-- sunflowers behind the fence
for _, x in ipairs({ 176, 200, 224 }) do
  c:fill(c:rect(x, 90, x + 1, 108), "#4a8a3e")
  c:part(c:ellipse(x, 88, 6, 6), GV.ramp("#f5cf6a", { shade = "#e8a317" }), { cres = 3, deep = 4, gloss = false })
  c:fill(c:ellipse(x, 88, 3, 3), "#5e2f1e")
end

-- painter's table and the gnome painter, foreground ------------------------------------------------------------------------------------------------------------------------------
c:part(c:rrect(30, 112, 70, 118, 2), GV.ramp("#d9a660"), { cres = 2, deep = 3, gloss = false })
c:part(c:rect(34, 118, 38, 134), GV.ramp("#8a4f2a"), { cres = 1, gloss = false, outline = false }); c:part(c:rect(62, 118, 66, 134), GV.ramp("#8a4f2a"), { cres = 1, gloss = false, outline = false })
for i, x in ipairs({ 36, 42, 48 }) do egg(x, 108, i - 1, 1) end
for i, col in ipairs({ RED, "#3f8fb0", "#f5cf6a", "#4a8a3e" }) do c:part(c:rect(54 + i * 3, 109, 56 + i * 3, 111), GV.ramp(col), { flat = true, gloss = false, outline = false }) end
gnome(96, 128, "#d6322b", "#3f8fb0")
c:limb({ {88, 122}, {80, 116}, {72, 112} }, 3)
egg(70, 108, 4, 2)
c:fill(c:rect(70, 104, 70, 103), "#2a1a10")
-- a big stool basket of finished eggs at front left
c:part(c:ellipse(30, 130, 16, 7):cut(c:rect(10, 132, 52, 140)), GV.ramp("#c9a96e"), { cres = 3, deep = 5, gloss = false })
for i, x in ipairs({ 18, 25, 32, 39, 45 }) do egg(x, 124 + (i % 2), i + 5, 1) end
c:part(c:rrect(14, 128, 46, 134, 2), GV.ramp("#c9a96e"), { cres = 2, gloss = false })
c:seam({ {16, 131}, {44, 131} }, { on = 2, off = 1 })
-- hen and chicks
c:part(c:ellipse(130, 122, 9, 6), GV.ramp("#f08a24", { shade = "#a8582f" }), { cres = 3, deep = 4, gloss = false })
c:part(c:ellipse(121, 115, 5, 5), GV.ramp("#f08a24"), { cres = 2, gloss = false })
c:fill(c:rect(118, 108, 121, 110), RED); c:fill(c:rect(116, 116, 118, 117), "#f5cf6a"); c:eye(120, 113, true)
c:fill(c:rect(129, 128, 129, 131), "#e8a317"); c:fill(c:rect(134, 128, 134, 131), "#e8a317")
for _, p in ipairs({ {144,126},{152,130},{160,124} }) do
  c:part(c:ellipse(p[1], p[2], 3, 3), GV.ramp("#f5cf6a"), { flat = true, gloss = false }); c:px(p[1] - 1, p[2] - 1, "#2a1a10"); c:px(p[1] - 4, p[2], "#f08a24")
end

L.finish(c, "haven-painted-egg-house")
