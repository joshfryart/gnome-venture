-- progress-sprout FINAL (= pass B; history: progress-sprout.pA.lua, progress-sprout.pB.lua). 18x18 progress icon: two-leaf sprout in a mound of soil.
-- B: leaves re-cut as pointed ovals with midribs and a lit upper edge, stem 2 px with a lit side, soil mound with
-- clods and a deep underside, dewdrop with glint. Matched set with progress-gnome / progress-house.
-- quirk: a dewdrop on the left leaf.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../lib/hp.lua")
local out = app.params.out or (DIR .. "/")
local NAME = app.params.name or "progress-sprout"
local c = HP.canvas{ w = 18, h = 18, scale = 1, name = NAME }
c:paint({
  "..................",
  "..........GGgg....",
  "..GG.....GGggggg..",
  ".GAGg...GGgggghh..",
  ".GagggG.Gghhhgh...",
  "..gghggGghgggh....",
  "...gggghghhhj.....",
  ".....hhjgh........",
  "........Gh........",
  "........gh........",
  "........gh........",
  "....BBbbGhbbbt....",
  "..BBbbbbghbbbbtt..",
  ".BbbbubbbbbbbbPtt.",
  ".bbbbbbbbbtbbbQtt.",
  ".tbbbbbbbbbbbtttu.",
  "..uutttttttttuuu..",
  "..................",
}, 0, 0, {
  G = "moss.hi", g = "moss.base", h = "moss.shade", j = "moss.deep",
  B = "wood.hi", b = "wood.base", t = "wood.shade", u = "wood.deep",
  A = "sea.hi", a = "sea.base", P = "stone.hi", Q = "stone.shade",
})
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
