local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local ped = c:poly({ {24, 38}, {40, 38}, {44, 49}, {20, 49} })
local foot = c:rrect(16, 47, 47, 52, 1)
local lip = c:rect(22, 38, 41, 40)
local disc = c:ellipse(31.5, 25, 15, 15)
local p = c:build{
  { "foot", foot, GV.ramp("#5b6470") },
  { "ped", ped, GV.ramp("#968f96") },
  { "lip", lip, GV.ramp("#5b6470"), { flat = true } },
  { "disc", disc, GV.ramp("#d6c9b6"), { gloss = { 24, 17 } } },
}
-- seam on plinth lip
c:seam({ {18, 48}, {45, 48} })
-- hour ticks around inner rim
local tk = "#5b6470"
local function tick(x0, y0, x1, y1) c:fill(c:line({ {x0, y0}, {x1, y1} }, 1), tk) end
tick(31, 13, 32, 13); tick(31, 14, 32, 14)      -- 12
tick(43, 24, 43, 25); tick(44, 24, 44, 25)      -- 3
tick(31, 36, 32, 36); tick(31, 37, 32, 37)      -- 6
tick(19, 24, 19, 25); tick(20, 24, 20, 25)      -- 9
c:px(40, 16, tk); c:px(41, 17, tk)              -- diagonals
c:px(22, 16, tk); c:px(21, 17, tk)
c:px(40, 34, tk); c:px(41, 33, tk)
c:px(22, 34, tk); c:px(21, 33, tk)
-- shadow wedge right of gnomon
c:fill(c:poly({ {33, 27}, {41, 27}, {42, 30}, {33, 30} }), "#a8a4a8")
-- gnomon
local g = c:poly({ {30, 14}, {33, 14}, {42, 28}, {30, 28} })
c:fill(g, "#5b6470")
c:fill(g:edge(), "#2a1a10")
c:fill(c:line({ {31, 16}, {31, 26} }, 1), "#8b8f96")
c:fill(c:ellipse(31.5, 27.5, 2, 1.5), "#3e3a48")
local t = c:save(O .. "aseprite/ph/sundial.aseprite", O .. "png/ph/sundial.png")
print(GV.report(t))
