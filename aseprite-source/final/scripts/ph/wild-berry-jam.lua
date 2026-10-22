local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local glass = GV.ramp("#a9d6ea", { gloss = "#c8ecdc" })
local jam = GV.ramp("#d6322b", { base = "#dd3a2a", shade = "#ae2a2a" })
local lid = GV.ramp("#e8a317", { rim = "#f5cf6a", shade = "#b8661a" })
local cream = GV.ramp("#f4f0e0")

-- squat jar: wide shoulders, short neck under the lid
local jar = c:rrect(13, 25, 50, 54, 8)
jar:add(c:rect(18, 22, 45, 27))
local fill = c:rrect(16, 31, 47, 51, 6)
local lidm = c:rrect(15, 13, 48, 24, 4)
local label = c:rrect(21, 36, 42, 46, 2)

local p = c:build{
  { "jar", jar, glass, { gloss = false } },
  { "jam", fill, jam, { gloss = false } },
  { "lid", lidm, lid, { gloss = { 20, 15 } } },
  { "label", label, cream, { gloss = false, contour = "#4a2c1a" } },
}

-- glass sheen strip on the upper-left of the jar
c:fill(c:rect(15, 30, 15, 44), "#c8ecdc")
c:fill(c:rect(16, 28, 16, 29), "#c8ecdc")
c:px(15, 47, "#c8ecdc")

-- lid ridges (screw grooves)
for x = 19, 45, 4 do c:fill(c:rect(x, 17, x, 21), lid.shade) end
c:seam({ { 16, 23 }, { 47, 23 } })

-- berry on the label: three dark beads and a leaf
c:paint({
  "....gg..",
  "..ggg...",
  ".rr.rr..",
  "rrrrrrr.",
  "rrrrrrr.",
  ".rrrrr..",
  "..rrr...",
  "...r....",
}, 28, 37, { r = "#6b1b2c", g = "#4a8a3e" })
c:px(29, 40, "#ae2a2a"); c:px(32, 40, "#ae2a2a"); c:px(30, 42, "#ae2a2a")

-- jam seeds / glints
c:px(19, 34, "#ff9158"); c:px(44, 49, "#6b1b2c"); c:px(18, 48, "#6b1b2c")

local t = c:save(O .. "aseprite/ph/wild-berry-jam.aseprite", O .. "png/ph/wild-berry-jam.png")
print(GV.report(t))
