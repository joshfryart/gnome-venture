-- ph/birdbath : stone birdbath, basin of water on a pedestal with a flared foot
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local stone = GV.ramp("#8b8f96", { rim = "#c9c5bc" })

-- flared foot: trapezoid plinth with a lip
local foot = c:poly({ {22, 44}, {42, 44}, {47, 51}, {17, 51} }):add(c:rrect(16, 48, 47, 53, 2))
-- column: slightly waisted
local col = c:rect(28, 28, 36, 46):add(c:rect(27, 41, 37, 46))
-- basin: wide rim ellipse plus a bowl underside
local basin = c:ellipse(31.5, 20, 21, 7.5)
basin:add(c:ellipse(31.5, 23, 17, 9):cut(c:rect(0, 0, 63, 22)))
basin:add(c:rect(26, 29, 37, 33))
local water = c:ellipse(31.5, 19.5, 16.5, 4.5)

c:build{
  { "foot",  foot,  stone },
  { "col",   col,   stone },
  { "basin", basin, stone, { light = basin:copy():add(col):add(foot) } },
  { "water", water, "water", { contact = false, gloss = { 20, 18 } } },
}
-- ripple ring
c:paint({
  "...wwwww...",
  ".ww.....ww.",
  "w.........w",
  ".ww.....ww.",
  "...wwwww...",
}, 29, 17, { w = "#c8ecdc" })
c:px(34, 19, GV.R.water.deep)
-- plinth lip seam
c:seam({ {19, 50}, {45, 50} })

local t = c:save(O .. "aseprite/ph/birdbath.aseprite", O .. "png/ph/birdbath.png")
print(GV.report(t))
