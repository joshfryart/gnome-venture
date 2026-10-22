local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local gem = c:poly({ {32,8}, {51,26}, {32,57}, {13,26} })
local p = c:build{
  { "gem", gem, "moss", { gloss = { 22, 21 } } },
}
local function ln(pts, w, hex) local m = c:line(pts, w); m:clip(gem:shrink(2)); c:fill(m, hex) end
ln({ {15,25}, {49,25} }, 1, "#a4b86a")
ln({ {32,10}, {24,25} }, 1, "#c8d77a")
ln({ {32,10}, {40,25} }, 1, "#c8d77a")
ln({ {24,25}, {32,55} }, 1, "#2f5a2a")
ln({ {40,25}, {32,55} }, 1, "#2f5a2a")
-- pupil slit
local pup = c:rrect(29, 23, 34, 41, 2)
c:fill(pup:grow(1), "#2f5a2a")
c:fill(pup, "#2a1a10")
c:px(30, 25, "#fff1c8"); c:px(30, 26, "#fff1c8")
c:px(33, 38, "#3e2f66")
local t = c:save(O .. "aseprite/ph/jade-eye.aseprite", O .. "png/ph/jade-eye.png")
print(GV.report(t))
