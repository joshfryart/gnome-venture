local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local mound = c:ellipse(31.5, 46, 22, 9)
local top = c:ellipse(31.5, 43, 17, 4.5)
-- sprouts: round leaf bumps with a short stem
local sl = c:ellipse(21.5, 37, 3.5, 3.5); sl:add(c:rect(21, 39, 22, 43))
local sm = c:ellipse(31.5, 34, 4, 3.5); sm:add(c:rect(31, 36, 32, 42))
local sr = c:ellipse(41.5, 37, 3.5, 3.5); sr:add(c:rect(41, 39, 42, 43))
c:build{
  { "mound", mound, GV.ramp("#8c4a1a") },
  { "top", top, GV.ramp("#a5663a"), { contact = false } },
  { "sl", sl, "moss", { cres = 2, deep = 1 } },
  { "sm", sm, GV.ramp("#58a03e"), { cres = 2, deep = 1 } },
  { "sr", sr, "moss", { cres = 2, deep = 1 } },
}
-- leaf vein notch on each sprout

-- soil crumbs
c:px(15, 47, "#5e2f1e"); c:px(46, 48, "#5e2f1e"); c:px(27, 50, "#5e2f1e"); c:px(37, 51, "#5e2f1e")
local t = c:save(O .. "aseprite/ph/stage-herb-1.aseprite", O .. "png/ph/stage-herb-1.png")
print(GV.report(t))
