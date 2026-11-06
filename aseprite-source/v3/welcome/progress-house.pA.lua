-- progress-house PASS A. 18x18 progress icon: cottage, red roof, cream walls, round wooden door, chimney.
-- Matched set with progress-gnome / progress-sprout (same red as the gnome hat, same ink outline and light).
-- quirk: a little curl of chimney smoke.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../lib/hp.lua")
local out = app.params.out or (DIR .. "/")
local NAME = app.params.name or "progress-house.pA"
local c = HP.canvas{ w = 18, h = 18, scale = 1, name = NAME }
c:paint({
  "..................",
  "............S.....",
  "...........SSs....",
  "...........tt.....",
  "......Rr...bt.....",
  ".....RRrr..bt.....",
  "....RRrrrrrrrs....",
  "...RRrrrrrrrrrs...",
  "..Rrrrrrrrrrrrrs..",
  ".ddddddddddddddddd",
  "..CCcccccccccccq..",
  "..CcAacccbbbcccq..",
  "..CcaAccbBbbtccq..",
  "..ccccccbBbbtccq..",
  "..ccccccbbbYtccq..",
  "..ccccccbbbbtcqq..",
  "..qqqqqqbbbbtqqq..",
  "..................",
}, 0, 0, {
  R = "ember.hi", r = "ember.base", s = "ember.shade", d = "ember.deep",
  C = "cream", c = "#f3e2bd", q = "#d9bf92",
  B = "wood.hi", b = "wood.base", t = "wood.shade", u = "wood.deep",
  A = "sea.hi", a = "sea.base", Y = "gold.hi", S = "stone.hi", s = "ember.shade",
})
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
