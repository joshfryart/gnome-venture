-- creature-ashen-ant : blight-sick trek ant, the colour of cold ashes.
-- Three-quarter front view: it has turned off the scent trail to face you.
-- Big grey head turned to the viewer, raised segmented gaster behind, drooping club antennae.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local ash   = GV.ramp("#8b8f96")              -- stone family: cold ash grey (gaster)
local cind  = GV.ramp("#5b6470")              -- stone dark: cinder head
local thx   = GV.ramp("#737880")              -- between the two (thorax)
local pale  = GV.ramp("#c9c5bc")              -- stone pale: ash flakes, mandibles

-- legs (behind everything), bent 2 px lavender, all from the thorax
c:limb({ {32,38}, {31,45}, {34,52} })         -- front, planted
c:limb({ {36,39}, {42,44}, {43,52} })         -- mid
c:limb({ {39,36}, {48,39}, {53,47} })         -- hind

-- antennae: elbowed, 4x4 clubs; the left one hangs limp (it has stopped tasting the trail), the right one raised at you
local antL = c:line({ {14,31}, {11,21}, {8,25} }, 2)
local antR = c:line({ {23,31}, {26,22}, {29,17} }, 2)
local clubs = c:rrect(6, 25, 9, 28, 1):add(c:rrect(29, 13, 32, 16, 1))

-- gaster: big raised egg behind, tilted up-right
local gaster = c:ellipse(46, 22, 10, 8.5):add(c:ellipse(41, 26, 5, 4.5))

local p = c:build{
  { "antL",   antL, cind, { flat = true } },
  { "antR",   antR, cind, { flat = true } },
  { "clubs",  clubs, pale, { flat = true, contour = false } },
  { "gaster", gaster, ash },
  { "petiole", c:ellipse(35.5, 30.5, 2.5, 2.5), thx, { flat = true } },
  { "thorax", c:ellipse(33, 36, 5, 4), thx },
  { "head",   c:ellipse(19, 40, 10.5, 10), cind },
  { "mandL",  c:ascii({ "pp....", "ppp...", ".ppp..", "..pppp", "...ppp" }, 11, 49), pale, { flat = true } },
  { "mandR",  c:ascii({ "....pp", "...ppp", "..ppp.", "pppp..", "ppp..." }, 21, 49), pale, { flat = true } },
}

-- gaster segment seams (the real joins of the abdomen)
c:seam({ {40,17}, {42,23}, {44,30} })
c:seam({ {48,14}, {51,21}, {52,29} })

-- ash flakes: pale beans on the gaster, evenly varied
c:spot(c:ellipse(45, 18, 1.5, 1), pale.base, pale.gloss)
c:spot(c:ellipse(53, 23, 1, 1.5), pale.base, pale.gloss)
c:spot(c:ellipse(47, 27, 1.5, 1), pale.base, pale.gloss)

-- face: locked eyes set wide, staring straight at you; flat cold mouth
c:eye(11, 36); c:eye(21, 36)
c:paint({ "uu...", "..uuu" }, 10, 33, { u = "#2a1a10" })   -- low fixed brows: a stare
c:paint({ "...uu", "uuu.." }, 21, 33, { u = "#2a1a10" })
c:paint({ "uuuu" }, 16, 45, { u = "#2a1a10" })

c:ground(30, 56, 22, 1.5)
local t = c:save(D .. "final/aseprite/ph/creature-ashen-ant.aseprite", PNG .. "creature-ashen-ant.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
