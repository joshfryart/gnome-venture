-- quartz-shell: the Quartz Snail's empty shell. A squat slate coil lying on its side,
-- open mouth to the lower right, with a crown of three quartz crystals growing out of
-- the top. Same slate ramp and lavender quartz veins as creature-quartz-snail.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local slate = GV.ramp("#5b6470", { base = "#4a5160" })   -- stone family (as the snail shell)
local quartz = GV.ramp("#8f7fc9")                         -- lavender quartz (snail's vein colour)
local V = "#d8d0f5"

-- coil body: round whorl, slightly wider than tall
local coil = c:ellipse(29.5, 40.5, 19, 15)
-- open mouth: a lip flaring at the lower right
local lip = c:ellipse(45, 47, 9, 8)
local mouth = c:ellipse(46, 48, 5.5, 4.5)
-- crystals, back to front: left, tall centre, right
local crL = c:poly({ { 13, 36 }, { 10, 22 }, { 12, 15 }, { 17, 17 }, { 25, 29 }, { 25, 36 } })
local crC = c:poly({ { 21, 32 }, { 23, 14 }, { 30, 5 }, { 36, 14 }, { 37, 32 } })
local crR = c:poly({ { 34, 34 }, { 39, 20 }, { 46, 13 }, { 51, 18 }, { 47, 34 } })

local all = coil:copy():add(lip):add(crL):add(crC):add(crR)
local p = c:build{
  { "crL",  crL,  quartz, { light = all, gloss = false } },
  { "crR",  crR,  quartz, { light = all, gloss = false } },
  { "coil", coil, slate,  { light = all, gloss = { 14, 38 } } },
  { "crC",  crC,  quartz, { light = all, gloss = { 26, 15 } } },
  { "lip",  lip,  GV.ramp("#8b8f96"), { light = all, gloss = false } },
}
-- crystal facet lines: one central ridge per crystal, lit left face
local function facet(m, pts) c:fill(c:line(pts, 1):clip(m:shrink(1)), V) end
facet(p.crC.m, { { 30, 8 }, { 30, 31 } })
facet(p.crL.m, { { 13, 18 }, { 19, 31 } })
facet(p.crR.m, { { 46, 16 }, { 41, 31 } })
-- whorl: a spiral groove on the coil, in slate shade with a lavender vein beside it
local pts = {}
for i = 0, 50 do
  local th = i / 50 * 1.6 * 2 * math.pi
  local r = 1.5 + th * 1.35
  pts[#pts + 1] = { math.floor(28 + math.cos(th + 2.6) * r + 0.5), math.floor(43 + math.sin(th + 2.6) * r * 0.85 + 0.5) }
end
local groove = c:line(pts, 2):clip(coil:shrink(2)):cut(lip:grow(1))
c:fill(groove, slate.deep)
c:fill(c:line(pts, 1):shift(-1, -1):clip(coil:shrink(2)):cut(lip:grow(1)):cut(groove), "#8f7fc9")
-- dark mouth
c:fill(mouth, "#2a1a10")
c:fill(c:ellipse(45, 47, 3.5, 2.5):clip(mouth), "#291d4a")

local t = c:save(D .. "final/aseprite/ph/quartz-shell.aseprite", PNG .. "quartz-shell.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
