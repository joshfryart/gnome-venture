local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- kidney: two lobes joined, with a concave notch on the lower side
local bean = c:ellipse(32, 29, 21, 14):add(c:ellipse(19, 32, 9, 11)):add(c:ellipse(45, 31, 9, 12))
bean:cut(c:ellipse(31, 55, 13, 13))
local p = c:build{
  { "bean", bean, GV.ramp("#8c4a1a", { deep = "#5e2f1e" }), { gloss = {22, 22} } },
}
-- hilum slit in the notch
c:paint({ "..ucccu..", "ucccccccu" , ".u.....u."}, 27, 36, { u = "umber", c = "#f1ece0" })
-- mottled streaks
local S = { s = "#44281c" }
c:paint({ "ss..", ".sss" }, 36, 23, S)
c:paint({ "sss.", "..ss" }, 44, 36, S)
c:paint({ "ss", ".s", ".s" }, 17, 28, S)
local t = c:save(O .. "aseprite/ph/kidney-bean.aseprite", O .. "png/ph/kidney-bean.png")
print(GV.report(t))
