-- ph/ember-spark : cut-gem kite spark, flat girdle and long lower point
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local lime = GV.ramp("#b0bc66")  -- moss family, lime
local facet = "#58a03e"

-- crown: flat table on top, shoulders at y 24; pavilion: long point to y 58 (3 px wide tip)
local gem = c:poly({ {26,6}, {39,6}, {53,24}, {34,57}, {31,57}, {12,24} })
c:build{
  { "gem", gem, lime, { gloss = { 22, 16 } } },
}

-- facet lines (drawn after the part)
local function ln(pts, w) c:fill(c:line(pts, w):clip(gem:shrink(1)), facet) end
ln({ {13,24}, {52,24} }, 2)           -- girdle
ln({ {25,25}, {32,56} }, 2)           -- lower facets
ln({ {40,25}, {33,56} }, 2)
ln({ {26,7}, {22,24} }, 2)            -- crown facets
ln({ {39,7}, {43,24} }, 2)
ln({ {27,7}, {38,7} }, 2)             -- table edge

-- bright top glint (crown, lit side)
c:fill(c:rect(29, 12, 31, 14), "#c8d77a")
c:px(30, 13, "#fff1c8")

local t = c:save(O .. "aseprite/ph/ember-spark.aseprite", O .. "png/ph/ember-spark.png")
print(GV.report(t))
