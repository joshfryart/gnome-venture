-- progress-sprout PASS A. 18x18 progress icon: two-leaf sprout in a mound of soil.
-- Matched set with progress-gnome / progress-house. quirk: a dewdrop on the left leaf.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../lib/hp.lua")
local out = app.params.out or (DIR .. "/")
local NAME = app.params.name or "progress-sprout.pA"
local c = HP.canvas{ w = 18, h = 18, scale = 1, name = NAME }
c:paint({
  "..................",
  "..........GGgg....",
  ".GGg.....GGgggg...",
  ".Gggg...Gggggghh..",
  ".gAggg..gggghhh...",
  "..gaggh.ghhhj.....",
  "...gghhj.g........",
  ".....hhjgh........",
  "........gh........",
  "........gh........",
  "........gh........",
  "....BBbbghbbt.....",
  "..BBbbbbbbbbbtt...",
  ".Bbbbbubbbbbbtttt.",
  ".bbbbbbbbbubbbttt.",
  ".tttbbbbbbbbtttuu.",
  "..uuutttttttuuuu..",
  "..................",
}, 0, 0, {
  G = "moss.hi", g = "moss.base", h = "moss.shade", j = "moss.deep",
  B = "wood.hi", b = "wood.base", t = "wood.shade", u = "wood.deep",
  A = "sea.hi", a = "sea.base",
})
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
