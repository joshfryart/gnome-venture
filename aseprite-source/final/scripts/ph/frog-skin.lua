local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local hide = c:ellipse(31.5, 27, 10, 9)
hide:add(c:ellipse(31.5, 41, 9, 9))
-- wavy scalloped top (head)
hide:add(c:ellipse(25.5, 18, 3.5, 3)); hide:add(c:ellipse(31.5, 16, 3.5, 3)); hide:add(c:ellipse(37.5, 18, 3.5, 3))
-- wavy bottom
hide:add(c:ellipse(26.5, 49, 3, 2.5)); hide:add(c:ellipse(31.5, 51, 3, 2.5)); hide:add(c:ellipse(36.5, 49, 3, 2.5))
-- arms reaching up-out, two toes each
hide:add(c:line({ {23,27}, {18,24}, {15,21} }, 5))
hide:add(c:line({ {15,21}, {12,17} }, 3)); hide:add(c:line({ {15,22}, {11,22} }, 3))
hide:add(c:line({ {40,27}, {45,24}, {48,21} }, 5))
hide:add(c:line({ {48,21}, {51,17} }, 3)); hide:add(c:line({ {48,22}, {52,22} }, 3))
-- legs reaching down-out, two toes each
hide:add(c:line({ {25,44}, {19,48}, {16,51} }, 5))
hide:add(c:line({ {16,52}, {12,52} }, 3)); hide:add(c:line({ {17,53}, {15,56} }, 3))
hide:add(c:line({ {38,44}, {44,48}, {47,51} }, 5))
hide:add(c:line({ {48,52}, {52,52} }, 3)); hide:add(c:line({ {47,53}, {49,56} }, 3))
local p = c:build{ { "hide", hide, "moss", { gloss = { 25, 21 } } } }
local B = "#58a03e"
c:fill(c:line({ {26,25}, {25,29}, {26,33} }, 2), B)
c:fill(c:line({ {36,29}, {38,33}, {36,37} }, 2), B)
c:fill(c:line({ {27,42}, {31,40}, {35,42} }, 2), B)
c:seam({ {24,48}, {28,51}, {32,53}, {36,51}, {40,48} })
local t = c:save(O .. "aseprite/ph/frog-skin.aseprite", O .. "png/ph/frog-skin.png")
print(GV.report(t))
