local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local bowl = c:ellipse(31.5, 28, 21, 20):clip(c:rect(0, 28, 63, 63))
local mound = c:ellipse(31.5, 29, 17, 15):clip(c:rect(0, 0, 63, 29))
for _, b in ipairs({ {17,24,4}, {22,19,4}, {28,15,4}, {35,15,4}, {41,19,4}, {46,24,4} }) do
  mound:add(c:ellipse(b[1], b[2], b[3]))
end
mound:clip(c:rect(0, 0, 63, 29))
c:build{
  { "bowl",  bowl, GV.ramp("#f4f0e0") },
  { "mound", mound, GV.ramp("#f1ece0"), { gloss = { 24, 15 } } },
  { "rim",   c:rrect(10, 27, 53, 30, 1), GV.ramp("#d6c9b6"), { gloss = false } },
  { "beanA", c:ellipse(22.5, 22, 3.5, 3), GV.ramp("#c9a96e"), { gloss = false } },
  { "beanB", c:ellipse(33.5, 19, 3.5, 3), "moss", { gloss = false } },
  { "beanC", c:ellipse(42.5, 24, 3.5, 3), "gold", { gloss = false } },
}
for _, b in ipairs({ {21,21}, {32,18}, {41,23} }) do c:px(b[1], b[2], "#fff3c8") end
-- a few rice grains
for _, g in ipairs({ {18,26}, {27,25}, {30,21}, {37,25}, {47,27}, {26,18}, {39,16} }) do
  c:paint({ "gg" }, g[1], g[2], { g = "#e3d6bc" })
end
c:seam({ {12, 28}, {51, 28} })
c:ground(31.5, 48, 13, 1.5)
local t = c:save(B .. "aseprite/ph/rice-and-beans.aseprite", B .. "png/ph/rice-and-beans.png")
print(GV.report(t))
