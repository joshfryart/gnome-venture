local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local mound = c:ellipse(31.5, 50, 25, 31):cut(c:rect(0, 51, 63, 99))
local arch = c:ellipse(31.5, 40, 13, 13):cut(c:rect(0, 51, 63, 99)):add(c:rect(19, 40, 44, 50))
local door = c:ellipse(31.5, 40, 9, 9):cut(c:rect(0, 51, 63, 99)):add(c:rect(23, 40, 40, 50))
local p = c:build{
  { "pole", c:rect(31, 9, 32, 20), "#44281c", { flat = true } },
  { "flag", c:poly({ { 33, 9 }, { 42, 12 }, { 33, 16 } }), GV.ramp("#d6322b"), { gloss = false } },
  { "mound", mound, GV.ramp("#58a03e"), { stitch = { side = "lit" }, gloss = { 18, 28 } } },
  { "arch", arch, GV.ramp("#968f96"), { gloss = false } },
  { "door", door, GV.ramp("#a5663a"), { gloss = { 27, 35 } } },
}
-- stone blocks on the arch
c:px(25, 29, "#5b6470"); c:px(38, 29, "#5b6470")
c:px(20, 38, "#5b6470"); c:px(43, 38, "#5b6470"); c:px(20, 45, "#5b6470"); c:px(43, 45, "#5b6470")
-- plank lines
for _, x in ipairs({ 27, 32, 36 }) do
  for y = 31, 50 do if door:has(x, y) then c:px(x, y, "#44281c") end end
end
-- knob
c:paint({ ".g.", "ggG", ".G." }, 37, 42, { g = "#f5cf6a", G = "#b8661a" })
-- grass ticks
c:paint({ "k.k", ".k." }, 13, 31, { k = "#2e5a2c" })
c:paint({ "k.k", ".k." }, 48, 33, { k = "#2e5a2c" })
c:paint({ "k.k", ".k." }, 10, 43, { k = "#2e5a2c" })
c:seam({ { 9, 49 }, { 18, 49 } }); c:seam({ { 46, 49 }, { 54, 49 } })
c:ground(31.5, 51, 25, 1.5)
local t = c:save(O .. "aseprite/ph/root_cellar-2.aseprite", O .. "png/ph/root_cellar-2.png")
print(GV.report(t))
