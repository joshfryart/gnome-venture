local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local pot = c:ellipse(31.5, 39, 17, 15):add(c:rrect(22, 48, 41, 55, 2))
local band = c:rrect(17, 24, 46, 29, 2)
local lid = c:ellipse(31.5, 25, 15, 9):cut(c:rect(0, 26, 63, 63))
local knob = c:ellipse(31.5, 14, 4, 4)
local p = c:build{
  { "pot",  pot,  "water" },
  { "band", band, GV.ramp("#f1ece0"), { gloss = false } },
  { "lid",  lid,  GV.ramp("#8fcbd8") },
  { "knob", knob, GV.ramp("#dcb06a") },
}
-- fruit on the belly, with stem and leaf
c:part(c:ellipse(32, 41, 6, 6), GV.ramp("#4a6fc0", { deep = "#256a80" }), { contour = "#2a3c6c" })
c:fill(c:rect(32, 33, 33, 35), "#2f5a2a")
c:part(c:poly({ {34, 34}, {37, 30}, {42, 29}, {40, 33}, {36, 35} }), GV.ramp("#58a03e"), { flat = true })
c:seam({ {18, 26}, {45, 26} })
c:button(30, 20)
local t = c:save(O .. "aseprite/ph/osmanthus-seed.aseprite", O .. "png/ph/osmanthus-seed.png")
print(GV.report(t))
