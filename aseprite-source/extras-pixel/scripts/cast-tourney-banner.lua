-- puzzles/cast/tourney-banner.png: 400x120 (drawn 200x60, out=2). Tournament day on the meadow:
-- Jeff centre with a stopwatch, Ffej sneaking in from the left, the trophy on a plinth at the right, bunting above.
-- Families: sky = water, meadow = moss, plinth = wood/stone, trophy = gold, bunting = Part A bases.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local CAST = dofile(D .. "extras-pixel/scripts/cast-lib.lua")(GV)
local PNG = "/home/user/gnome-venture/game/assets/img/puzzles/cast/"
local ASE = D .. "extras-pixel/cast/"
local W, H = 200, 60

local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2, ol = 1, olx = 1, cres = 3, deep = 1 }
-- sky, far hills, meadow
c:bands(c:rect(0, 0, W - 1, 35), { "#7fc0de", "#8ac6e1", "#95cce4", "#a0d2e7", "#abd8ea" }, { dir = "v" })
c:part(c:ellipse(40, 44, 70, 14):clip(c:rect(0, 0, W - 1, 44)), GV.ramp("#94c46e"), { gloss = false, outline = false, cres = 5 })
c:part(c:ellipse(170, 42, 80, 12):clip(c:rect(0, 0, W - 1, 44)), GV.ramp("#a4cf78"), { gloss = false, outline = false, cres = 5 })
local mead = c:rect(0, 44, W - 1, H - 1)
for x = 0, W - 1, 6 do mead:add(c:poly({ { x, 45 }, { x + 3, 41 }, { x + 6, 45 } })) end
c:part(mead, GV.ramp("#7ab55c"), { flat = true, rim = false, outline = false, contour = false })
c:bands(c:rect(0, 50, W - 1, H - 1), { "#74b057", "#6eab52", "#68a64d" }, { dir = "v" })
-- clouds
local function cloud(list)
  local m = c:mask()
  for _, e in ipairs(list) do m:add(c:ellipse(e[1], e[2], e[3], e[4])) end
  c:part(m, GV.ramp("#f1ece0"), { outline = false, cres = 3 })
  c:outline(m, { pale = m:grow(3) })
end
cloud{ { 44, 22, 7, 4 }, { 52, 18, 7, 6 }, { 60, 22, 6, 4 } }
cloud{ { 150, 16, 6, 4 }, { 157, 13, 6, 5 }, { 164, 16, 5, 3 } }
-- bunting: a string across the top with alternating felt flags
local STR = { { 0, 4 }, { 50, 9 }, { 100, 6 }, { 150, 9 }, { W - 1, 4 } }
c:fill(c:line(STR, 1), "#4a2c1a")
local FL = { "#dd3a2a", "#f5cf6a", "#3f8fb0", "#e46a9b", "#7ab55c", "#8a5fd0" }
local n = 0
for i = 1, #STR - 1 do
  local a, b = STR[i], STR[i + 1]
  for t = 0.1, 0.95, 0.2 do
    local x, y = a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t
    local flag = c:poly({ { x - 4, y + 1 }, { x + 5, y + 1 }, { x + 0.5, y + 10 } })
    n = n + 1
    c:part(flag, GV.ramp(FL[n % #FL + 1]), { gloss = false, cres = 2, deep = 1 })
  end
end
-- trophy on a stone plinth at the right
local plinth = c:rrect(150, 36, 186, 50, 1)
c:part(plinth, GV.ramp("#8b8f96"), { gloss = { 152, 38 }, cres = 3, deep = 1 })
c:seam({ { 151, 40 }, { 185, 40 } })
c:fill(c:rect(150, 36, 186, 36), "#c9c5bc")
CAST.trophy(c, 168, 35, 30, false)
c:ground(168, 51, 18, 2)
-- Ffej sneaking in from the left, Jeff centre with the stopwatch
CAST.ffej(c, 18, 36, 0.7, { pose = "sneak" })
c:ground(18, 52, 14, 2)
CAST.jeff(c, 100, 30, 0.8, { pose = "watch" })
c:ground(100, 48, 15, 2)
-- a few flowers in the front
local function flower(x, y, col)
  c:part(c:line({ { x, y + 8 }, { x, y + 2 } }, 2), GV.ramp("#4a8a3e"), { flat = true, outline = false })
  local head = c:ellipse(x, y - 2, 1.5, 1.5):add(c:ellipse(x + 2, y, 1.5, 1.5)):add(c:ellipse(x, y + 2, 1.5, 1.5)):add(c:ellipse(x - 2, y, 1.5, 1.5))
  c:part(head, GV.ramp(col), { gloss = false, cres = 2, deep = 0 })
  c:px(x, y, "#e8a317"); c:px(x - 1, y - 1, "#f5cf6a")
end
flower(60, 50, "#e46a9b"); flower(134, 53, "#f5cf6a"); flower(44, 55, "#dd3a2a"); flower(192, 54, "#f1ece0")
local t = c:save(ASE .. "tourney-banner.aseprite", PNG .. "tourney-banner.png")
print("tourney-banner", GV.report(t))
assert(t.semi == 0 and t.bw <= 4) -- pale dot on the wizard beard
