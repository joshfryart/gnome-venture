local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local mound = c:ellipse(31.5, 52, 25, 5)
local tent = c:poly({ {7, 53}, {31, 14}, {33, 14}, {57, 53} })
local door = c:poly({ {24, 53}, {32, 31}, {41, 53} })
local flag = c:poly({ {33, 6}, {40, 8}, {33, 11} })
local pole = c:rect(32, 6, 33, 15)
local log = c:rrect(42, 52, 54, 55, 1)
local flame = c:ellipse(48, 48, 4, 4):add(c:poly({ {44, 48}, {48, 40}, {53, 48} })):add(c:ellipse(50, 42, 1.5, 2))
local p = c:build{
  { "mound", mound, "moss" },
  { "pole", pole, "#5e3a24", { flat = true } },
  { "flag", flag, GV.ramp("#e0501f"), { flat = true } },
  { "tent", tent, GV.ramp("#d6322b"), { stitch = { side = "lit" } } },
  { "door", door, GV.ramp("#f5cf6a"), { gloss = false } },
  { "log", log, "wood", { gloss = false } },
  { "flame", flame, GV.ramp("#f08a24"), { gloss = false } },
}
-- door centre slit
for y = 33, 52 do c:px(32, y, "#2a1a10") end
c:fill(c:ellipse(48, 49, 1.5, 2), "#f5cf6a")
c:seam({ {25, 51}, {31, 34} }, { gap = nil })
c:seam({ {33, 34}, {39, 51} })
c:button(30, 16)
local t = c:save(O .. "aseprite/ph/lm-haven.aseprite", O .. "png/ph/lm-haven.png")
print(GV.report(t))
