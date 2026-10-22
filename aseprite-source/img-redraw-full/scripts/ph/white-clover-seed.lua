local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- clover sprout behind the envelope: stem + three round leaves
local stem = c:rect(31, 16, 32, 22)
local leaves = c:ellipse(27.5, 16, 4, 3.5):add(c:ellipse(37.5, 16, 4, 3.5)):add(c:ellipse(32.5, 11.5, 3.5, 3.5))
local body = c:rrect(22, 20, 42, 54, 2)
local flap = c:poly({ {22, 20}, {43, 20}, {32.5, 34} })
local p = c:build{
  { "stem", stem, "moss", { flat = true } },
  { "leaves", leaves, GV.ramp("#58a03e"), { cres = 2 } },
  { "body", body, "cream", { light = body } },
  { "flap", flap, GV.ramp("#e0d8c0"), { gloss = false, cres = 2 } },
  { "wax", c:ellipse(32.5, 33, 3, 3), "moss", { gloss = { 31, 31 } } },
}
-- leaf veins (pale centre lines)
c:px(27, 16, GV.R.moss.gloss); c:px(38, 16, GV.R.moss.gloss); c:px(32, 11, GV.R.moss.gloss)
-- fold line down the front
for y = 38, 52 do if y % 3 ~= 0 then c:px(32, y, "#dcb06a") end end
-- seed dots
local seed = { "ss", "ss" }
c:paint(seed, 26, 45, { s = "#dcb06a" }); c:paint(seed, 35, 41, { s = "#dcb06a" }); c:paint(seed, 36, 48, { s = "#dcb06a" })
c:ground(32.5, 56, 13, 1.5)
local t = c:save(O .. "aseprite/ph/white-clover-seed.aseprite", O .. "png/ph/white-clover-seed.png")
print(GV.report(t))
