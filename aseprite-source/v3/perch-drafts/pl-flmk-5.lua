-- pl-flmk-5-perch : 36x36 perch sprite (chibi moss-sprite pal on a soil perch)
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-flmk-5-perch-20261120-185036/"
local GV = dofile(D .. "gvlib/gvlib.lua")

local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 1 }

-- ramps from the pal's palette
local olive = GV.ramp("#826d54")                 -- body/head moss-olive
local gld   = GV.ramp("#d0a24a")                 -- spike + accent gold
local soil  = GV.ramp("#b4814f", { gloss = "#d8a05c", dot = "#d8a05c", rim = "#d8a05c" }) -- perch

-- SHADE/TEXTURE: ramps + crescents; per-part fixes from notes
local parts = c:build{
  { "spikes", c:poly({ { 7, 9 }, { 10, 9 }, { 8, 4 } })
               :poly({ { 11, 8 }, { 14, 8 }, { 12, 4 } })
               :poly({ { 15, 8 }, { 18, 8 }, { 16, 3 } })
               :poly({ { 18, 8 }, { 21, 8 }, { 20, 4 } })
               :poly({ { 21, 9 }, { 24, 9 }, { 23, 5 } })
               :poly({ { 24, 9 }, { 25, 9 }, { 26, 6 } }),
               gld, { flat = true, gloss = false, contact = false } },
  { "perch",  c:ellipse(17.5, 26.5, 10, 3), soil, { cres = 3, deep = 2, gloss = { 12, 25 }, bounce = false } },
  { "body",   c:rrect(12, 18, 24, 26, 4), olive },
  { "head",   c:ellipse(17.5, 13, 10, 7), olive, { cres = 3, deep = 2, gloss = { 12, 10 } } },
}

-- TEXTURE: tone-on-tone, hand-placed, <=1 tone step, follows the form
-- soil joints on the perch (curved, following the mound)
c:paint({
  ".N.o.", ".N.o.", ".N.o.",
}, 9, 25, { N = "#8a553b", o = "#b4814f" })
c:paint({ "N", "N", "N" }, 24, 25, { N = "#8a553b" })
-- 1px dither at the head light/shade border
c:paint({ "K", "K" }, 20, 12, { K = "#6b5845" })
c:px(19, 15, "#6b5845"); c:px(21, 17, "#6b5845")
-- tiny moss pits on the body (shade dot + lit dot pairs)
c:px(14, 21, "#6b5845"); c:px(15, 21, "#a79b77")
c:px(14, 23, "#a79b77")
-- edge wear: 2px chipped bits on the perch rim
c:px(26, 27, "#8a553b"); c:px(10, 28, "#8a553b")

-- DETAIL: face, marking, accent dots
-- eyes: 5x5 locked, set wide, below the gloss
c:eye(11, 12); c:eye(20, 12)
-- tiny 2px mouth
c:px(16, 17, "#2a1a10"); c:px(17, 17, "#2a1a10")
-- purple bean marking on the body (tone-on-tone accent from the pal's palette)
c:paint({
  ".pp",
  "ppp",
}, 13, 21, { p = "#653270" })
c:px(13, 21, "#8e7ab0")
-- two gold float-dots beside the perch, glinted
c:paint({ "GG", "GG" }, 29, 21, { G = "#d0a24a" }); c:px(29, 21, "#e7cd8e")
c:paint({ "GG", "GG" }, 30, 25, { G = "#d0a24a" }); c:px(30, 25, "#e7cd8e")

c:ground(17.5, 29.5, 10.5, 1.5)

local t = c:save(D .. "out/pl-flmk-5-perch.aseprite", D .. "out/pl-flmk-5-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 1)
