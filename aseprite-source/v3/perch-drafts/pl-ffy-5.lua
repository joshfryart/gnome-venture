-- pl-ffy-5-perch: 36x36 perch sprite, stitched-toy style, light from upper-left
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-ffy-5-perch-20261120-182247/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1 }

local SAGE   = "#6c817a"   -- body
local SAND   = "#eae092"   -- fronds / accent
local DARK   = "#2a3a2a"   -- perch mound
local PLUM   = "#2b1c26"   -- eyes / smile / line work

local rsand = GV.ramp(SAND)
local rsage = GV.ramp(SAGE)
local rdark = GV.ramp(DARK)

local p = c:build{
  { "fronds", c:mask()
    :line({{13,11},{9,8},{8,6}}, 2)
    :line({{15,10},{13,7},{12,6}}, 2)
    :line({{17,10},{17,6}}, 2)
    :line({{20,10},{21,7},{21,6}}, 2)
    :line({{22,11},{24,8},{25,6}}, 2), SAND, { flat = true, rim = true, contact = false } },
  { "mound", c:rrect(10, 24, 25, 28, 3), DARK, { flat = true } },
  { "body",  c:ellipse(17.5, 17, 9, 9), SAGE, { gloss = { 12, 12 } } },
  { "pawL",  c:rrect(11, 26, 14, 28, 1), SAGE, { flat = true } },
  { "pawR",  c:rrect(22, 26, 25, 28, 1), SAGE, { flat = true } },
  { "flower", c:rrect(26, 26, 29, 28, 1), SAND, { flat = true, contact = false } },
}

-- face (chibi: big round eyes, tiny mouth)
c:build{
  { "eyeL", c:rrect(12, 14, 14, 17, 1), PLUM, { flat = true, rim = false, gloss = false, contact = false, contour = false } },
  { "eyeR", c:rrect(20, 14, 22, 17, 1), PLUM, { flat = true, rim = false, gloss = false, contact = false, contour = false } },
  { "smile", c:line({{14,21},{17,23},{20,21}}, 1), PLUM, { flat = true, rim = false, gloss = false, contact = false, contour = false } },
}

-- texture: hand-placed, one shade step, following the form
c:fill(p.mound.m:clip(c:mask():rrect(20, 25, 24, 27, 1)), rdark.shade)   -- mound right end
c:px(8, 6, rsand.shade); c:px(9, 7, rsand.shade)                         -- frond tips
c:px(12, 6, rsand.shade); c:px(13, 6, rsand.shade)
c:px(17, 6, rsand.shade)
c:px(21, 6, rsand.shade)
c:px(25, 6, rsand.shade); c:px(24, 7, rsand.shade)
c:fill(c:ascii({ "uu", "u.u" }, 14, 19, "u"), rsage.shade)               -- bean marking
c:fill(c:ascii({ "uu" }, 21, 13, "u"), rsage.shade)                      -- bean marking
c:px(23, 14, SAGE); c:px(19, 22, rsage.shade); c:px(14, 24, rsage.shade) -- terminator dither

-- detail: glints, seed, spark
c:px(13, 15, SAND); c:px(21, 15, SAND)                                   -- eye glints
c:px(27, 27, PLUM)                                                       -- flower seed
c:px(27, 26, rsand.dot)                                                  -- flower glint
c:fill(c:rrect(28, 16, 29, 17, 1), SAND)                                 -- spark accent
c:px(28, 16, rsand.dot)

c:ground(17.5, 31, 10, 1.2, PLUM)

local t = c:save(D .. "out/pl-ffy-5-perch.aseprite", D .. "out/pl-ffy-5-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 2)
