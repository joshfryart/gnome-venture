local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local outer = c:poly({ {32,8},{55,20},{51,47},{32,57},{13,47},{9,20} })
local inner = c:poly({ {32,15},{46,23},{43,41},{32,48},{21,41},{18,23} })
local p = c:build{
  { "outer", outer, GV.ramp("#7b66b4", { gloss = "#a894dc" }), { light = outer } },
  { "inner", inner, GV.ramp("#54447f"), { gloss = false, light = outer } },
}
-- cross segments
c:fill(c:line({ {20,29},{44,29} }, 2):clip(inner), "#291d4a")
c:fill(c:line({ {22,38},{42,38} }, 2):clip(inner), "#291d4a")
-- centre spine (lighter ridge with dark edge)
local spine = c:line({ {32,10},{32,53} }, 2):clip(outer:shrink(2))
c:fill(spine, "#a894dc")
c:fill(spine:shift(1,0):cut(spine), "#3e2f66")
-- diamond sheen
c:paint({ ".s.", "sGs", ".s." }, 26, 30, { s = "#7b66b4", G = "#a894dc" })
local t = c:save(O .. "aseprite/ph/ant-chitin.aseprite", O .. "png/ph/ant-chitin.png")
print(GV.report(t))
