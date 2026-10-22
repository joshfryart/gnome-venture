local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local bone = GV.ramp("#f8eed2")
local cran = c:ellipse(31.5, 27, 21, 19)
local jaw = c:rrect(21, 39, 42, 55, 4)
c:build{
  { "jaw", jaw, bone },
  { "cran", cran, bone, { gloss = { 17, 17 } } },
}
local dark = "#3a2e2a"
c:fill(c:ellipse(23.5, 30, 5.5, 6.5), dark)
c:fill(c:ellipse(39.5, 30, 5.5, 6.5), dark)
-- socket inner glow pixels (toy friendly)
c:px(21, 27, "#5e4a44"); c:px(37, 27, "#5e4a44")
c:paint({ "ddd", ".d." }, 30, 38, { d = dark })
c:fill(c:rect(31, 46, 32, 54), dark)
c:fill(c:rect(25, 46, 26, 54), "#c9b48c")
c:fill(c:rect(37, 46, 38, 54), "#c9b48c")

local t = c:save(O .. "aseprite/ico/ico-skull.aseprite", O .. "png/ico/ico-skull.png")
print(GV.report(t))
