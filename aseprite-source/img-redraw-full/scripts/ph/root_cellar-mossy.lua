local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- wide grassy dome (base at y 46)
local mound = c:ellipse(31.5, 46, 26, 31):cut(c:rect(0, 47, 63, 200))
mound:cut(c:rect(0, 0, 63, 11))
mound:add(c:ellipse(31.5, 18, 16, 7):cut(c:rect(0, 19, 63, 200)))
-- stone arch and wooden door
local arch = c:ellipse(31.5, 33, 13.5, 13):cut(c:rect(0, 34, 63, 200))
arch:add(c:rect(18, 33, 45, 46))
local door = c:ellipse(31.5, 35, 9.5, 10):cut(c:rect(0, 36, 63, 200))
door:add(c:rect(22, 35, 41, 46))

local hill = GV.ramp("#58a03e", { gloss = "#c8d77a", shade = "#4a8a3e", deep = "#2f5a2a" })
c:build{
  { "mound", mound, hill },
  { "arch", arch, GV.ramp("#968f96"), { gloss = false } },
  { "door", door, GV.ramp("#a5663a"), { gloss = { 25, 30 } } },
  { "tuftL", c:ellipse(15, 18, 5, 3.5), "moss", { light = mound } },
  { "tuftT", c:ellipse(37, 11, 6, 3.5), "moss", { light = mound } },
  { "tuftR", c:ellipse(50, 22, 4.5, 3), "moss", { light = mound } },
  { "tuftBL", c:ellipse(11, 41, 4, 3):cut(c:rect(0, 45, 63, 200)), "moss", { gloss = false } },
  { "tuftBR", c:ellipse(52, 41, 4, 3):cut(c:rect(0, 45, 63, 200)), "moss", { gloss = false } },
  { "moss on arch", c:ellipse(25, 21, 4, 2.5):add(c:ellipse(30, 20, 3, 2)), "moss", { gloss = false } },
}
-- plank lines
for _, x in ipairs({ 27, 32, 37 }) do
  c:fill(c:rect(x, (x == 32) and 26 or 29, x, 45), "#44281c")
end
-- door knob
c:paint({ ".g.", "ggs", ".s." }, 38, 37, { g = "#f5cf6a", s = "#b8661a" })
-- moss drips down the sides
c:fill(c:rect(9, 28, 10, 32), "#4a8a3e"); c:fill(c:rect(9, 33, 9, 34), "#4a8a3e")
c:fill(c:rect(53, 26, 54, 30), "#4a8a3e"); c:fill(c:rect(54, 31, 54, 32), "#4a8a3e")
c:ground(31.5, 49, 25, 1.5)
local t = c:save(O .. "aseprite/ph/root_cellar-mossy.aseprite", O .. "png/ph/root_cellar-mossy.png")
print(GV.report(t))
