-- pack-seeds PASS A. 32x32 pack header icon (step 3 "Maplewold seeds"): crimped paper seed packet, torn open
-- at the top, a two-leaf sprout growing out of it. Paper: crimp ridges, crease line, label with a bean, dog-eared
-- corner. Leaves: lit upper half, midrib, darker lower half.
-- quirk: a ladybird riding the right leaf.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../lib/hp.lua")
local out = app.params.out or (DIR .. "/")
local NAME = app.params.name or "pack-seeds.pA"
local c = HP.canvas{ w = 32, h = 32, scale = 1, name = NAME }
c:paint({
  "................................", -- 0
  "........................gGGgi...", -- 1
  ".....................gGGGGgggi..", -- 2
  "....gGg............krRrrGgggii..", -- 3
  "...gGGGgg..........kkrkrgggiii..", -- 4
  "...iiiGGggg....GhggggggggiiihI..", -- 5
  "...hhhiiiggggg.GhgGggggiiihhhI..", -- 6
  "....hhhhhiiiiggGhggiiiihhhhIj...", -- 7
  "......jhhhhhhiiGhiihhhhhjj......", -- 8
  ".........jjjhhhGhhjjjj..........", -- 9
  "...............Gi...............", -- 10
  "......a.a.a....gi....c.d.e......", -- 11
  "......bababaoooghooooacdcde.....", -- 12
  "......bcbcbcaoogiooaacdcdee.....", -- 13
  "......deeeeeeaaaaaaeeeeeeef.....", -- 14
  "......abaaccccccccccccccdee.....", -- 15
  "......abcccccccccccccccdee......", -- 16
  "......abcWWWWWWWWWWWwvcdee......", -- 17
  "......abcWWWWWWWWWWWwvcdee......", -- 18
  "......abcWWWWWBbnWWWwvcdee......", -- 19
  "......abcWWWWBbbnnWWwvcdee......", -- 20
  "......abcWWWWbbnnnmWwvcdee......", -- 21
  "......abcWWWWbnnnmmWwvcdee......", -- 22
  "......abcWWWWWnnmmmWwvcdee......", -- 23
  "......abcWWWWWWmmmWWwvcdee......", -- 24
  "......abcWWWWWWWWWWWwvcdee......", -- 25
  "......abcWWvvvvvvvvWwvcdee......", -- 26
  "......abccwwwwwwwwwwvaabf.......", -- 27
  "......abccccccccccccccabf.......", -- 28
  "......abdddddddddddddbf.........", -- 29
  "......beeeeeeeeeeeeeef..........", -- 30
  "................................", -- 31
}, 0, 0, {
  a = "#ffd0dc", b = "#ffa8c0", c = "#f5809f", d = "#de6890", e = "#c94f84", f = "#7d2c5e", o = "#4a1e3c",
  W = "#fff4d6", w = "#f3dfb4", v = "#d9b07a",
  B = "#f08a6a", b = "#d0563f", n = "#a83a35", m = "#6e2632", I = "moss.deep",
  G = "#e0f29a", g = "moss.hi", h = "moss.base", i = "moss.shade", j = "moss.deep",
  r = "ember.base", R = "ember.hi", k = "#2b1c26",
})
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
