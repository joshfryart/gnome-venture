local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tin = GV.ramp("#c9c5bc", { shade = "#8b8f96" })
-- hinge knuckles poke out at the back corners
local hinges = c:rect(6, 21, 9, 25):add(c:rect(54, 19, 57, 23))
-- lid tilted up: right edge 2 px higher
local lid = c:poly({ {11, 16}, {53, 14}, {56, 17}, {56, 26}, {53, 28}, {11, 28}, {8, 25}, {8, 19} })
local p = c:build{
  { "hinge", hinges, "#5b6470", { flat = true } },
  { "body",  c:rrect(10, 26, 53, 52, 4), tin },
  { "label", c:rrect(17, 32, 46, 48, 3), "#f1ece0" },
  { "seed",  c:ellipse(31.5, 42, 7, 5.5), "#e46a9b" },
  { "lid",   lid, "#8b8f96" },
  { "lip",   c:rect(10, 25, 53, 27), "#5b6470", { gloss = false } },
}
-- sprout on the label
c:fill(c:rect(31, 33, 32, 37), "#4a8a3e")
c:fill(c:ascii({ ".xx.", "xxxx", ".xx." }, 33, 32), "#7ab55c")
c:px(34, 32, "#a4b86a")
c:seam({ {12, 26}, {51, 26} })
c:button(30, 19)
local t = c:save(O .. "aseprite/ph/hibiscus-seed.aseprite", O .. "png/ph/hibiscus-seed.png")
print(GV.report(t))
