local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- cover: wide boat shape, dips at the spine top and bottom
local cover = c:poly({ {8, 14}, {32, 21}, {57, 14}, {57, 49}, {32, 56}, {8, 49} })
-- pages: splayed V, slight curl at the outer top corners
local left  = c:poly({ {10, 12}, {31, 19}, {31, 50}, {10, 44} })
left:add(c:ellipse(12, 13, 2, 1.5))
local right = c:poly({ {55, 12}, {34, 19}, {34, 50}, {55, 44} })
right:add(c:ellipse(52, 13, 2, 1.5))

local pale = "#f8eed2"
local p = c:build{
  { "cover", cover, "#8a4f2a" },
  { "left",  left,  pale, { gloss = { 13, 16 } } },
  { "right", right, pale, { gloss = false } },
}

-- spine channel
c:fill(c:poly({ {31, 19}, {34, 19}, {34, 56}, {31, 56} }), "#5e2f1e")

-- chunky slanted text lines (3 px), following the page slope
local ink = "#d9a660"
c:fill(c:line({ {15, 25}, {26, 29} }, 3), ink)
c:fill(c:line({ {15, 33}, {26, 37} }, 3), ink)
c:fill(c:line({ {50, 25}, {39, 29} }, 3), ink)
c:fill(c:line({ {50, 33}, {39, 37} }, 3), ink)


local t = c:save(O .. "aseprite/ico/ico-book-open.aseprite", O .. "png/ico/ico-book-open.png")
print(GV.report(t))
