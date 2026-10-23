-- ph/clean-dew : one bright round bead of clean water resting on a leaf tip, with a clean sparkle
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- water family, lifted brighter and clearer than the murky blighted pools
local dew = GV.ramp("#4aa8cc", { gloss = "#e6faf0", dot = "#f4fcf6", rim = "#9adbe6",
                                 shade = "#2f7aa8", deep = "#2a4c80", bounce = "#5aa0c8" })

-- leaf: a long lens lying across the bottom, tip to the right, little stalk on the left
local leaf = c:poly({ { 11, 47 }, { 20, 41 }, { 34, 38 }, { 47, 38 }, { 56, 42 },
                      { 47, 49 }, { 34, 53 }, { 20, 53 } })
leaf = leaf:closed(2)
local stalk = c:line({ { 7, 51 }, { 12, 48 } }, 2)
-- bead: a round drop, slightly squashed where it sits on the leaf
local bead = c:ellipse(31.5, 30, 14, 13)
bead:cut(c:rect(0, 42, 63, 63))
bead:add(c:ellipse(31.5, 40, 12, 3))

local p = c:build{
  { "stalk", stalk, "leaf", { flat = true } },
  { "leaf",  leaf, "leaf", { gloss = { 17, 45 } } },
  { "bead",  bead, dew, { gloss = { 23, 23 } } },
}
-- leaf midrib, kept off the bead
local rib = c:line({ { 12, 48 }, { 24, 47 }, { 38, 45 }, { 54, 42 } }, 1)
rib:clip(p.leaf.m:shrink(1)); rib:cut(p.bead.m:grow(1))
c:fill(rib, GV.R.leaf.rim)
-- light gathered inside the drop on the far (lower-right) side: a bright caustic arc
local caus = c:ellipse(33, 32, 9, 8):cut(c:ellipse(31, 30, 9, 8)):clip(p.bead.m:shrink(3))
c:fill(caus, "#a8e4ec")
-- clean sparkle: a 4-point star on the upper right of the bead
c:paint({ "..s..", "..s..", "ssGss", "..s..", "..s.." }, 35, 20, { s = "#c8ecdc", G = "#f4fcf6" })

local t = c:save(D .. "final/aseprite/ph/clean-dew.aseprite", PNG .. "clean-dew.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
