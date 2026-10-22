local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local R = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local p = c:build{
  { "hingeL", c:rect(15, 14, 18, 19), GV.ramp("#5b6470"), { flat = true } },
  { "hingeR", c:rect(45, 14, 48, 19), GV.ramp("#5b6470"), { flat = true } },
  { "body", c:rrect(10, 28, 54, 54, 4), GV.ramp("#8b8f96") },
  { "lid", c:rrect(9, 17, 55, 29, 4), GV.ramp("#c9c5bc") },
  { "ring", c:ellipse(32, 42, 8, 8), GV.ramp("#3f93b2"), { gloss = false } },
  { "window", c:ellipse(32, 42, 6, 6), GV.ramp("#f4f0e0"), { gloss = false, rim = false } },
  { "seed", c:ellipse(32, 44, 3.5, 3), GV.ramp("#3f93b2"), { flat = true } },
  { "stem", c:rect(31, 38, 32, 41), "moss", { flat = true } },
  { "leaf", c:ellipse(34.5, 38, 2, 1), "moss", { flat = true } },
}
c:px(30, 43, "#c8ecdc")
-- rivets
c:px(13, 32, "#5b6470"); c:px(51, 32, "#5b6470")
c:px(13, 51, "#5b6470"); c:px(51, 51, "#5b6470")
-- lid seam with clasp
c:seam({ {12, 28}, {29, 28} }); c:seam({ {35, 28}, {52, 28} })
c:button(30, 27)
local t = c:save(R .. "aseprite/ph/desert-rose-seed.aseprite", R .. "png/ph/desert-rose-seed.png")
print(GV.report(t))
