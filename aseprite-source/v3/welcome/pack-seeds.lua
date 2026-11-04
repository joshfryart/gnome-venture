-- pack-seeds FINAL (= pass B; history pack-seeds.pA, pack-seeds.pB). 32x32 pack header icon (step 3 "Maplewold seeds"): crimped paper seed packet, torn open
-- at the top, a two-leaf sprout growing out of it. Paper: crimp ridges, crease line, label with a bean, dog-eared
-- corner. Leaves: lit upper half, midrib, darker lower half.
-- B: whole drawing re-cut to a 1 px margin; taller, narrower packet (portrait) under wider leaves; 2-row gap so leaves
-- and packet separate; leaves re-cut with midribs; 4x3 ladybird with spots; bigger bean with glint; clean dog-ear
-- with crease and contact shadow; torn V opening.
-- quirk: a ladybird riding the right leaf.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../lib/hp.lua")
local out = app.params.out or (DIR .. "/")
local NAME = app.params.name or "pack-seeds"
local c = HP.canvas{ w = 32, h = 32, scale = 1, name = NAME }
c:paint({
  "................................", -- 0
  "................................", -- 1
  "........................gGGgi...", -- 2
  "....................rRrGGggih...", -- 3
  ".....gGGg..........kRrkqgiihi...", -- 4
  "....igGGgggg...Gh.gkrkrqihhi....", -- 5
  "....hiigGggggg.GhGgggiihhhi.....", -- 6
  "....hhhiiggggggGhggiihhij.......", -- 7
  ".....hhhhiiggggGhiihjj..........", -- 8
  "......ihhhhiiggGh...............", -- 9
  "........jihhhiiGh...............", -- 10
  "...............Gh...............", -- 11
  "...............Gh...............", -- 12
  "........a.a.a..Gh..c.d.e........", -- 13
  "........bababaogioacdcde........", -- 14
  "........bcbcbcagiacdcdee........", -- 15
  "........deeeeeeeeeeeeeef........", -- 16
  "........abaaccccccccccde........", -- 17
  "........abcWWWWWWWWWwcde........", -- 18
  "........abWWBBbWWWWWwvde........", -- 19
  "........abWBKbbnWWWWwvde........", -- 20
  "........abWBbbnnmWWWwvde........", -- 21
  "........abWbbnnmWWWWwvde........", -- 22
  "........abWWnmmWWWWWwvde........", -- 23
  "........abWvvvvvvvWWwvde........", -- 24
  "........abcwwwwwwwwwvcde........", -- 25
  "........abccccccccccaabf........", -- 26
  "........abccccccccceabf.........", -- 27
  "........abdddddddddebf..........", -- 28
  "........beeeeeeeeeeef...........", -- 29
  "................................", -- 30
  "................................", -- 31
}, 0, 0, {
  a = "#ffd0dc", b = "#ffa8c0", c = "#f5809f", d = "#de6890", e = "#c94f84", f = "#7d2c5e", o = "#4a1e3c",
  W = "#fff4d6", w = "#f3dfb4", v = "#d9b07a",
  B = "#f08a6a", b = "#d0563f", n = "#a83a35", m = "#6e2632", I = "moss.deep",
  G = "#e0f29a", g = "moss.hi", h = "moss.base", i = "moss.shade", j = "moss.deep",
  r = "ember.base", R = "ember.hi", q = "ember.shade", k = "#2b1c26", K = "#fff4d6",
})
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
