-- progress-house PASS B (polish over A). 18x18 progress icon: cottage, red tiled roof, cream walls, round door.
-- B: roof re-cut wider with a deep eave and tile-course marks, arched (round-topped) door with lit edge and gold knob,
-- stone chimney, framed window, darker wall base; smoke puff detached and outlined. Matched set with
-- progress-gnome / progress-sprout (same red as the gnome hat). quirk: a little puff of chimney smoke.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../lib/hp.lua")
local out = app.params.out or (DIR .. "/")
local NAME = app.params.name or "progress-house.pB"
local c = HP.canvas{ w = 18, h = 18, scale = 1, name = NAME }
c:paint({
  "..................",
  "...........WW.....",
  "..........Ww......",
  "...........Sxz....",
  ".......Rr..Sxz....",
  "......RRrr.Sxz....",
  ".....RRrrrrrrr....",
  "....RRrrrrrrrrs...",
  "...Rrssrssrssrss..",
  "..RRrrrrrrrrrrrrs.",
  "..ddddddddddddddd.",
  "...CCcccbbtccccq..",
  "...CAAcbBbbtcccq..",
  "...CAacbBbbtcccq..",
  "...ccccbbbYtcccq..",
  "...ccccbbbbtcccq..",
  "...qqqqbbbbtqqqq..",
  "..................",
}, 0, 0, {
  W = "cream", w = "stone.hi", x = "stone.base", z = "stone.shade",
  R = "ember.hi", r = "ember.base", s = "ember.shade", d = "ember.deep",
  C = "cream", c = "#f3e2bd", q = "#d9bf92",
  B = "wood.hi", b = "wood.base", t = "wood.shade", u = "wood.deep",
  A = "sea.hi", a = "sea.base", Y = "gold.hi", S = "stone.hi",
})
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
