-- Grubfield Beetle: glossy black guard beetle, front view, right wing case
-- lifted on its hinge to show a gold nugget hidden underneath.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local shellR = GV.R.dusk
local headR  = GV.ramp("#291d4a", { gloss = "#a894dc", dot = "#c3b2ea", rim = "#7b66b4",
  shade = "#1e1438", deep = "#160e2c", bounce = "#3e2f66" })
local bellyR = GV.ramp("#54447f", { rim = "#7b66b4", gloss = "#a894dc", dot = "#c3b2ea",
  shade = "#3e2f66", deep = "#291d4a", bounce = "#4a3a7a" })

-- legs (behind everything), bent outward
c:limb({ {14, 35}, {9, 38}, {7, 43} })
c:limb({ {20, 47}, {14, 50}, {13, 55} })
c:limb({ {43, 47}, {49, 50}, {50, 55} })

-- closed left wing case
local elL = c:ellipse(31.5, 27, 20, 15):cut(c:rect(32, 0, 63, 63))
-- soft belly under the lifted right case
local belly = c:ellipse(40, 33, 10, 8)
-- gold nugget tucked under the case
local nug = c:ellipse(47.5, 35.5, 6, 5):add(c:ellipse(43, 37.5, 3, 2.5))
-- right wing case lifted up and out on its hinge
local elR = c:ellipse(42.5, 20, 13, 12.5):cut(c:rect(0, 0, 31, 63))
elR:add(c:poly({ {30, 13}, {36, 9}, {36, 26}, {32, 28} }))
elR:cut(c:poly({ {32, 31}, {56, 23}, {56, 40}, {32, 40} }))
local head = c:ellipse(31.5, 41, 13.5, 10)
local mand = c:line({ {26, 49}, {25, 53}, {28, 55} }, 2):add(c:line({ {37, 49}, {38, 53}, {35, 55} }, 2))

local p = c:build{
  { "belly", belly, bellyR, { gloss = false } },
  { "nug",   nug,   "gold", { gloss = { 45, 33 } } },
  { "elL",   elL,   shellR },
  { "elR",   elR,   shellR },
  { "mand",  mand,  shellR, { flat = true } },
  { "head",  head,  headR, { gloss = { 23, 34 } } },
}
-- belly segment lines
c:fill(c:line({ {38, 30}, {41, 34} }, 1):clip(p.belly.m:shrink(1)):cut(nug):cut(head), bellyR.shade)
-- extra glint on the nugget
c:px(49, 34, "#fff1c8"); c:px(50, 35, "#f5cf6a"); c:px(48, 35, "#f5cf6a")
-- suture seam on the closed case, button at the hinge
c:seam({ {29, 16}, {29, 31} })
c:button(28, 11)
-- enamel streak along the closed case (glossy shell)
c:paint({ "...gg", "..g..", ".g...", "g...." }, 18, 18, { g = shellR.gloss })
-- locked eyes set wide
c:eye(21, 38); c:eye(37, 38)

c:ground(31.5, 55, 17, 1.5)
local t = c:save(D .. "final/aseprite/ph/creature-grub-beetle.aseprite", PNG .. "creature-grub-beetle.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
