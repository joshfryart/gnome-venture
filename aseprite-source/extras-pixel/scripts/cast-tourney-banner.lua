-- puzzles/cast/tourney-banner.png: 400x120 (drawn 200x60, out=2). Tournament day on the meadow:
-- Jeff centre with a stopwatch, Ffej sneaking in from the left, the trophy on a plinth at the right, bunting above.
-- Also writes tourney-banner-dark.png: evening recolour (dusk sky, moon and stars, lit tents, dimmed cast).
-- Families: sky = water (day) / dusk (night), meadow = moss, plinth = wood/stone, trophy = gold, bunting = Part A bases.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local CAST = dofile(D .. "extras-pixel/scripts/cast-lib.lua")(GV)
local P = app.params or {}   -- --script-param out=<dir>/ ase=<dir>/ (staging); only=light|dark
local PNG = P.out or "/home/user/gnome-venture/game/assets/img/puzzles/cast/"
local ASE = P.ase or D .. "extras-pixel/cast/"
local W, H = 200, 60

local function scene(dark)
local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2, ol = 1, olx = 1, cres = 3, deep = 1 }
local dim = function(h) return CAST.dim(h, dark) end
-- sky, far hills, meadow
if dark then
  c:bands(c:rect(0, 0, W - 1, 35), { "#1c1f4a", "#232a5c", "#2a356c", "#334579", "#4a4a7e" }, { dir = "v" })
  for _, p in ipairs({ { 8, 14 }, { 30, 6 }, { 66, 18 }, { 92, 12 }, { 118, 20 }, { 140, 6 }, { 176, 14 }, { 194, 24 }, { 22, 26 }, { 112, 4 } }) do c:px(p[1], p[2], "#f5cf6a") end
  c:px(92, 12, "#fff1c8"); c:px(176, 14, "#fff1c8")
  c:part(c:ellipse(140, 27, 4, 4):cut(c:ellipse(142, 25.5, 3.5, 3.5)), GV.ramp("#f5cf6a"), { flat = true, outline = false })
else
c:bands(c:rect(0, 0, W - 1, 35), { "#7fc0de", "#8ac6e1", "#95cce4", "#a0d2e7", "#abd8ea" }, { dir = "v" })
end
c:part(c:ellipse(40, 44, 70, 14):clip(c:rect(0, 0, W - 1, 44)), GV.ramp(dark and "#4f7a52" or "#94c46e"), { gloss = false, outline = false, cres = 5 })
c:part(c:ellipse(170, 42, 80, 12):clip(c:rect(0, 0, W - 1, 44)), GV.ramp(dark and "#5a8558" or "#a4cf78"), { gloss = false, outline = false, cres = 5 })
-- far marquee tents on the hills (tournament depth)
local function tent(x, y, col)
  local m = c:poly({ { x - 7, y + 8 }, { x, y }, { x + 7, y + 8 } })
  c:part(m, GV.ramp(dim(col)), { gloss = false, cres = 2, deep = 1 })
  c:fill(c:rect(x, y + 4, x, y + 8), dark and "#f5cf6a" or "#4a2c1a")
  c:fill(c:line({ { x, y }, { x, y - 3 } }, 1), "#4a2c1a"); c:px(x + 1, y - 3, "#dd3a2a")
end
tent(72, 33, "#f1ece0"); tent(86, 35, "#dd3a2a"); tent(128, 33, "#3f8fb0")
local mead = c:rect(0, 44, W - 1, H - 1)
for x = 0, W - 1, 6 do mead:add(c:poly({ { x, 45 }, { x + 3, 41 }, { x + 6, 45 } })) end
c:part(mead, GV.ramp(dark and "#3f6a48" or "#7ab55c"), { flat = true, rim = false, outline = false, contour = false })
c:bands(c:rect(0, 50, W - 1, H - 1), dark and { "#3b6545", "#376042", "#335b3f" } or { "#74b057", "#6eab52", "#68a64d" }, { dir = "v" })
-- clouds
local function cloud(list)
  local m = c:mask()
  for _, e in ipairs(list) do m:add(c:ellipse(e[1], e[2], e[3], e[4])) end
  c:part(m, GV.ramp(dark and "#6a6494" or "#f1ece0"), { outline = false, cres = 3 })
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
    c:part(flag, GV.ramp(dim(FL[n % #FL + 1])), { gloss = false, cres = 2, deep = 1 })
  end
end
-- trophy on a stone plinth at the right
local plinth = c:rrect(150, 36, 186, 50, 1)
c:part(plinth, GV.ramp(dim("#8b8f96")), { gloss = { 152, 38 }, cres = 3, deep = 1 })
c:seam({ { 151, 40 }, { 185, 40 } })
c:fill(c:rect(150, 36, 186, 36), dim("#c9c5bc"))
CAST.trophy(c, 168, 35, 30, dark)
c:ground(168, 51, 18, 2)
-- Ffej sneaking in from the left, Jeff centre with the stopwatch
CAST.ffej(c, 18, 36, 0.7, { pose = "sneak", dark = dark })
c:ground(18, 52, 14, 2)
CAST.jeff(c, 100, 28, 0.88, { pose = "watch", dark = dark })
c:ground(100, 49, 16, 2)
-- a few flowers in the front
local function flower(x, y, col)
  c:part(c:line({ { x, y + 8 }, { x, y + 2 } }, 2), GV.ramp(dark and "#2f5a3a" or "#4a8a3e"), { flat = true, outline = false })
  local head = c:ellipse(x, y - 2, 1.5, 1.5):add(c:ellipse(x + 2, y, 1.5, 1.5)):add(c:ellipse(x, y + 2, 1.5, 1.5)):add(c:ellipse(x - 2, y, 1.5, 1.5))
  c:part(head, GV.ramp(dim(col)), { gloss = false, cres = 2, deep = 0 })
  c:px(x, y, "#e8a317"); c:px(x - 1, y - 1, "#f5cf6a")
end
flower(60, 50, "#e46a9b"); flower(134, 53, "#f5cf6a"); flower(44, 55, "#dd3a2a"); flower(192, 54, "#f1ece0"); flower(80, 54, "#8a5fd0"); flower(120, 55, "#f08a24")
local name = dark and "tourney-banner-dark" or "tourney-banner"
local t = c:save(ASE .. name .. ".aseprite", PNG .. name .. ".png")
print(name, GV.report(t))
assert(t.semi == 0 and t.bw <= 4) -- pale dot on the wizard beard
end
if P.only ~= "dark" then scene(false) end
if P.only ~= "light" then scene(true) end
