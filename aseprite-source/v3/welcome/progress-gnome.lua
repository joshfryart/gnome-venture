-- progress-gnome FINAL (= pass B; history: progress-gnome.pA.lua, progress-gnome.pB.lua). 18x18 progress icon: gnome head, red pointed hat, cream beard.
-- B: hat re-cut so the tip clearly folds over and hangs right, lit felt brim over a deep underside, taller eyes,
-- designed nose (lit tip, warm base, shade, shadow row on the moustache), beard strands, no ink mouth blob.
-- Matched set with progress-house / progress-sprout. quirk: the hat tip flops over to the right.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../lib/hp.lua")
local out = app.params.out or (DIR .. "/")
local NAME = app.params.name or "progress-gnome"
local c = HP.canvas{ w = 18, h = 18, scale = 1, name = NAME }
c:paint({
  "..................",
  ".........RRr......",
  "........RRrrsd....",
  "........Rrrrrsdd..",
  ".......RRrrrs.sd..",
  ".......Rrrrrrs..d.",
  "......RRrrrrrs....",
  ".....RRrrrrrrrs...",
  "..RRRRrrrrrrrrrss.",
  "..ddddddddddddddd.",
  "...KKkkkkkkkkkkn..",
  "...Kkkekkkkekkkn..",
  "..WKkkekLNkekknW..",
  "..WWkpkNNNnpkwvv..",
  "..WWWwwvvvvwwwvv..",
  "...WWwvwwwwvwvv...",
  "....WWwwwwwwvv....",
  "..................",
}, 0, 0, {
  L = "#ffd2b0",
  R = "ember.hi", r = "ember.base", s = "ember.shade", d = "ember.deep",
  K = "skinA.hi", k = "skinA.base", n = "skinA.shade", m = "skinA.deep", N = "#ec8a68",
  e = "ink", p = "petal.base",
  W = "cream", w = "#ecdcc0", v = "#c4ad8e",
})
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
