local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local mug = GV.ramp("#d6c9b6")
local handle = c:ellipse(44, 36, 8.5, 8):cut(c:ellipse(44, 36, 4.5, 4)):clip(c:rect(43, 0, 63, 63))
local body = c:rect(15, 22, 43, 40):add(c:rrect(15, 26, 43, 51, 10))
c:build{
  { "handle", handle, mug, { gloss = false } },
  { "body",   body, mug },
  { "rim",    c:ellipse(29, 22, 14.5, 4), "stone", { gloss = false } },
  { "cocoa",  c:ellipse(29, 22.5, 11.5, 2.5), GV.ramp("#8c4a1a"), { gloss = false, contour = false } },
}
c:px(23, 21, "#ecc58a"); c:px(24, 21, "#ecc58a"); c:px(25, 21, "#d9a660")
c:seam({ {16, 30}, {42, 30} })
-- steam curls
c:paint({ ".s", "s.", ".s", "s." }, 24, 11, { s = "#c9c5bc" })
c:paint({ ".s", "s.", ".s", "s." }, 32, 10, { s = "#c9c5bc" })
local t = c:save(O .. "aseprite/ico/ico-coffee.aseprite", O .. "png/ico/ico-coffee.png")
print(GV.report(t))
