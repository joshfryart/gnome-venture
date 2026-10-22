local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- open lid tilted back (parallelogram rising behind the box)
local lid = c:poly({ {17, 9}, {47, 9}, {53, 31}, {11, 31} })
local lidIn = c:poly({ {20, 13}, {44, 13}, {48, 29}, {16, 29} })
local box = c:rrect(11, 31, 52, 54, 3)
local opening = c:rect(15, 32, 48, 39)
local front = c:rect(11, 40, 52, 54):clip(box)

local p = c:build{
  { "lid", lid, "#c9c5bc" },
  { "box", box, "#8b8f96" },
}
-- lid underside (inside)
c:fill(lidIn, "#8b8f96")
c:fill(c:poly({ {20, 13}, {44, 13}, {45, 16}, {19, 16} }), "#5b6470")
c:fill(c:rect(21, 18, 22, 22), "#c9c5bc")
-- opening (dark interior) holding seeds
c:fill(opening, "#f1ece0")
c:fill(c:rect(15, 32, 48, 32), "#5b6470")
c:fill(c:rect(15, 33, 48, 33), "#c9a96e")
local pips = { {17, 34}, {22, 35}, {27, 34}, {32, 35}, {37, 34}, {42, 35} }
for _, s in ipairs(pips) do
  c:paint({ ".k.", "kkk", "kkk", ".k." }, s[1], s[2], { k = "#17361c" })
  c:px(s[1], s[2] + 1, "#5e8a5e")
end
c:fill(c:rect(15, 39, 48, 39), "#c9a96e")
-- front lip seam
c:seam({ {13, 40}, {50, 40} })
-- rind band on front
c:fill(c:rect(13, 44, 50, 50), "#58a03e")
for x = 14, 49, 6 do c:fill(c:rect(x, 44, x + 2, 50), "#7ab55c") end
c:fill(c:rect(13, 44, 50, 44), "#2f5a2a")
c:fill(c:rect(13, 51, 50, 51), "#c8d77a")
-- hinges
c:fill(c:rect(15, 28, 19, 32), "#5b6470"); c:px(16, 29, "#c9c5bc")
c:fill(c:rect(44, 28, 48, 32), "#5b6470"); c:px(45, 29, "#c9c5bc")
-- gloss on box
c:fill(c:rect(14, 42, 16, 42), "#f2f0ea")

c:ground(31.5, 56, 19, 1.5)
local t = c:save(O .. "aseprite/ph/watermelon-seed.aseprite", O .. "png/ph/watermelon-seed.png")
print(GV.report(t))
