-- pl-baob-4-perch.lua : 36x36 perch sprite for the baob-4 sprout pal
local GV = dofile("C:/Users/hello/AppData/Local/Temp/ollama-art/pl-baob-4-perch-20261120-165906/gvlib/gvlib.lua")
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-baob-4-perch-20261120-165906/"
local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 1, cres = 1, deep = 1 }

-- ramps pinned to the pal's palette
GV.R.greens = GV.ramp("#619f47", { gloss = "#b2dc85", rim = "#88b557", shade = "#367c49", deep = "#1e5335", bounce = "#4a9a45", dot = "#d8eeb0" })
GV.R.brown  = GV.ramp("#522d1d", { gloss = "#b8a468", rim = "#8a6a60", shade = "#2b1c26", deep = "#2b1c26", bounce = "#5e3a30" })
GV.R.trunk  = GV.ramp("#8a6a60", { gloss = "#b8a468", rim = "#b8a468", shade = "#573e48", deep = "#2b1c26", bounce = "#6e5a50" })
GV.R.teal   = GV.ramp("#51abab", { rim = "#6fc0bd", shade = "#2f6a68", deep = "#1e4442", bounce = "#5a9a90" })
GV.R.tan    = GV.ramp("#b8a468", { rim = "#d9c890", shade = "#8a6a60", deep = "#6a4a3a" })
GV.R.shadow = { base = "#573e48", rim = "#573e48", gloss = "#573e48", dot = "#573e48", shade = "#573e48", deep = "#573e48", bounce = "#573e48" }

-- phase 6: DETAIL - face (eyes, brow tufts, mouth, bowtie), crown irregular, accent tweaks
local p = c:build{
  { "shadow", c:ellipse(17.5, 30.5, 8, 1), "shadow", { flat = true, solid = false, rim = false, cres = 0, contact = false } },
  { "staff",  c:rect(28, 13, 29, 30), "brown", { cres = 1, deep = 1, gloss = false, contact = false } },
  { "perch",  c:rrect(10, 26, 25, 30, 2), "trunk", { cres = 1, deep = 1, gloss = false, contact = false } },
  { "lip",    c:rrect(10, 26, 25, 27, 1), "tan", { cres = 1, deep = 0, gloss = false, contact = false, flat = true } },
  { "orb",    c:ellipse(28.5, 10.5, 2, 2), "teal", { cres = 1, contact = false } },
  { "head",   c:ellipse(17.5, 18.5, 10, 9.5), "greens", { cres = 1, gloss = { 12, 13 } } },
  { "crown",  c:ascii({
      "g.......g.......g.",
      "gg..gg..gg..gg..gg",
      "gg..gg..gg..gg..gg",
      "gg..gg..gg..gg..gg",
      "gg..gg..gg..gg..gg",
      "gggggggggggggggggg",
      "gggggggggggggggggg",
    }, 10, 4), "greens", { cres = 0, deep = 0, gloss = false, solid = true } },
  { "arm",    c:ascii({
      ".g.",
      "ggg",
      ".g.",
    }, 4, 17), "greens", { flat = true, cres = 0, contact = false, solid = true } },
  { "seed",   c:ascii({ "d", "d", ".d" }, 4, 11), "tan", { flat = true, cres = 0, contact = false, solid = true } },
}

-- ---- texture (hand-placed, tone-on-tone) ----
for _, pt in ipairs{ {12, 29, 2}, {16, 30, 2}, {20, 29, 2}, {23, 29, 1}, {14, 30, 1}, {21, 29, 1} } do
  for i = 0, pt[3] - 1 do c:px(pt[1] + i, pt[2], "#573e48") end
end
c:px(12, 28, "#8a6a60"); c:px(17, 28, "#8a6a60"); c:px(22, 28, "#8a6a60")
c:px(28, 16, "#8a6a60"); c:px(28, 21, "#8a6a60"); c:px(28, 26, "#8a6a60")
c:px(29, 18, "#2b1c26"); c:px(29, 24, "#2b1c26")
-- crown: light tips on the tall spikes
c:px(10, 4, "#b2dc85"); c:px(18, 4, "#b2dc85"); c:px(26, 4, "#b2dc85"); c:px(14, 5, "#b2dc85"); c:px(22, 5, "#b2dc85")
-- head: rim/base dither upper-left, form dots at the chin
c:px(11, 11, "#88b557"); c:px(10, 14, "#88b557"); c:px(12, 10, "#88b557")
c:px(19, 27, "#367c49"); c:px(22, 26, "#367c49"); c:px(16, 28, "#367c49")
c:px(5, 18, "#367c49")

-- ---- face ----
-- brow tufts (pale marks over the eyes, as on the pal)
for _, q in ipairs{ {11, 13}, {12, 13}, {13, 13}, {12, 12}, {21, 13}, {22, 13}, {23, 13}, {23, 12} } do
  c:px(q[1], q[2], "#d9c890")
end
-- eyes: locked 5x5 cream discs with dark pupils + glints
c:eye(11, 15); c:eye(21, 15)
-- mouth: open dark grin
for x = 16, 18 do c:px(x, 20, "#2b1c26") end
for x = 15, 19 do c:px(x, 21, "#2b1c26") end
for x = 15, 19 do c:px(x, 22, "#2b1c26") end
c:px(15, 22, "#573e48"); c:px(19, 22, "#573e48")
-- bowtie at the chin
for x = 14, 19 do c:px(x, 23, "#51abab") end
c:px(14, 24, "#2f6a68"); c:px(15, 24, "#51abab")
c:px(16, 24, "#6fc0bd"); c:px(17, 24, "#6fc0bd")
c:px(18, 24, "#51abab"); c:px(19, 24, "#2f6a68")
c:px(14, 23, "#6fc0bd"); c:px(19, 23, "#6fc0bd")

local t = c:save(D .. "out/pl-baob-4-perch.aseprite", D .. "out/pl-baob-4-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 2)
