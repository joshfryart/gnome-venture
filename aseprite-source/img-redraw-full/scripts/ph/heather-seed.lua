local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cloth = GV.ramp("#f4f0e0")
local frill = c:poly({ {20, 22}, {19, 10}, {26, 15}, {32, 7}, {38, 15}, {45, 10}, {44, 22} })
local neck = c:poly({ {24, 20}, {40, 20}, {36, 28}, {28, 28} })
local p = c:build{
  { "body",  c:ellipse(31.5, 40, 17, 14), cloth },
  { "neck",  neck, GV.ramp("#f1ece0"), { gloss = false } },
  { "frill", frill, cloth, { cres = 3 } },
}
c:stitch(p.body.m)
-- berry peeking through the opening of the wrap
c:part(c:ellipse(31.5, 42, 7, 7), GV.ramp("#f08a24", { shade = "#e0501f" }))
c:part(c:ellipse(37, 34, 3, 1.5), GV.ramp("#58a03e"), { flat = true })
-- fold creases
c:fill(c:rect(19, 38, 20, 46), "#dcb06a")
c:fill(c:rect(43, 38, 44, 46), "#dcb06a")
-- string tie and bow
local str = c:rect(25, 24, 38, 25)
str:add(c:ellipse(26.5, 21.5, 2.5, 2))
str:add(c:ellipse(37.5, 21.5, 2.5, 2))
str:add(c:line({ {30, 26}, {28, 30} }, 2))
str:add(c:line({ {34, 26}, {36, 30} }, 2))
c:part(str, "wood", { flat = true })
c:px(26, 21, "#5e2f1e"); c:px(27, 22, "#5e2f1e")
c:px(37, 21, "#5e2f1e"); c:px(36, 22, "#5e2f1e")
local t = c:save(O .. "aseprite/ph/heather-seed.aseprite", O .. "png/ph/heather-seed.png")
print(GV.report(t))
