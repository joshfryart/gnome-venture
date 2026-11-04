-- progress-gnome PASS A. 18x18 progress icon: gnome head, red pointed hat, cream beard, designed round nose.
-- Matched set with progress-house / progress-sprout: hand-placed pixels, 4 tones per material, light upper-left,
-- ink outline from finish, subject fills x2..15 / y1..16. quirk: the hat tip flops over to the right.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../lib/hp.lua")
local out = app.params.out or (DIR .. "/")
local NAME = app.params.name or "progress-gnome.pA"
local c = HP.canvas{ w = 18, h = 18, scale = 1, name = NAME }
c:paint({
  "..................",
  "..........Rrs.....",
  ".........Rrrrs....",
  "........RRrrrrsd..",
  ".......RRrrrrrsdd.",
  "......RRrrrrrrs...",
  ".....Rrrrrrrrrrs..",
  "....Rrrrrrrrrrrrs.",
  "...dddddddddddddd.",
  "...KKkkkkkkkkkkn..",
  "...Kkekkkkkkekkn..",
  "...kkekkKNkkekkn..",
  "..WkpkkNNNnkkpkvW.",
  "..WWWwwkmmkkwwwvv.",
  "..WWWwwwwwwwwwwvv.",
  "...WWwwwwwwwwwvv..",
  ".....Wwwwwwwvv....",
  "..................",
}, 0, 0, {
  R = "ember.hi", r = "ember.base", s = "ember.shade", d = "ember.deep",
  K = "skinA.hi", k = "skinA.base", n = "skinA.shade", m = "skinA.deep", N = "#f29a7a",
  e = "ink", p = "petal.base",
  W = "cream", w = "#ecdcc0", v = "#c4ad8e",
})
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
