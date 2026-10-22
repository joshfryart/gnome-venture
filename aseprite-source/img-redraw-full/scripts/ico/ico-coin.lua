local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local body = c:ellipse(31.5, 31.5, 24, 24)
local face = c:ellipse(31.5, 31.5, 18, 18)
local ring = c:ellipse(31.5, 31.5, 12, 12):cut(c:ellipse(31.5, 31.5, 6.5, 6.5))
local p = c:build{
  { "body", body, "gold", { gloss = false } },
  { "face", face, GV.ramp("#f2cf4a"), { gloss = false } },
  { "ring", ring, GV.ramp("#dcb06a", { shade = "#b8661a", deep = "#7a3a14" }), { gloss = false } },
}
-- tilted glint bar on the lit upper-left of the face
c:fill(c:line({ {18,26}, {25,18} }, 3), "#fff1c8")
c:px(28, 16, "#fff1c8"); c:px(29, 16, "#fff1c8")
local t = c:save(O .. "aseprite/ico/ico-coin.aseprite", O .. "png/ico/ico-coin.png")
print(GV.report(t))
