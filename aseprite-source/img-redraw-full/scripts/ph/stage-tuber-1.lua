local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local mound = c:ellipse(32, 47, 21, 7.5)
local top = c:ellipse(32, 45, 16, 4)
local leaf = c:poly({ {28,47},{24,43},{20,38},{18,33},{18,28},{20,25},{24,24},{27,25},{24,28},{24,32},{27,37},{31,42},{34,47} })
local p = c:build{
  { "mound", mound, GV.ramp("#8c4a1a") },
  { "top", top, GV.ramp("#a5663a"), { gloss = false } },
  { "leaf", leaf, "moss", { gloss = { 20, 29 } } },
}
c:paint({ "v...", "v...", ".v..", "..v.", "...v", "....v" }, 21, 31, { v = GV.R.moss.shade })
c:px(41, 44, "#7a4a1f"); c:px(45, 46, "#7a4a1f"); c:px(19, 46, "#7a4a1f"); c:px(38, 47, "#c9a96e")
local t = c:save(O .. "aseprite/ph/stage-tuber-1.aseprite", O .. "png/ph/stage-tuber-1.png")
print(GV.report(t))
