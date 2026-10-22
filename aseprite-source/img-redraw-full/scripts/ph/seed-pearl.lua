local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local pearl = c:ellipse(31.5, 32.5, 17, 17)
c:part(pearl, GV.ramp("#f4f0e0", { shade = "#cfe0b0", deep = "#a4b86a" }), { gloss = false, cres = 5, deep = 2 })
-- green swirl band across the lower half
c:fill(c:line({ {19, 37}, {24, 41}, {31, 43}, {38, 42}, {44, 38} }, 2), "#a4b86a")
c:fill(c:line({ {22, 36}, {26, 39}, {31, 40} }, 1), "#cfe0b0")
-- big enamel gloss comma, upper left
c:paint({
  "...gggg.",
  ".gggggg.",
  "ggggg...",
  "ggg.....",
  "gg......",
}, 20, 21, { g = "#fff3c8" })
c:px(21, 21, "#ffffff"); c:px(22, 21, "#ffffff")
c:px(27, 28, "#fff3c8")
local t = c:save(O .. "aseprite/ph/seed-pearl.aseprite", O .. "png/ph/seed-pearl.png")
print(GV.report(t))
