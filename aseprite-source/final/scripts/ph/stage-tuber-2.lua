local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local moss = GV.ramp("#7ab55c", { gloss = "#c8d77a", shade = "#2f5a2a" })
local dark = GV.ramp("#4a8a3e", { gloss = "#c8d77a" })
c:build{
  { "mound", c:ellipse(32, 47, 19, 5), "#7a4a1f", { gloss = false } },
  { "top",   c:ellipse(32, 46, 15, 3.5), "#9a6b3f", { gloss = false } },
  { "lleaf", c:poly({ {25,48},{19,43},{16,38},{15,32},{20,33},{25,37},{28,42},{29,48} }), moss },
  { "rleaf", c:poly({ {31,48},{30,42},{30,36},{32,30},{36,33},{38,38},{37,43},{35,48} }), dark },
}
-- leaf midribs
c:paint({ "v...", ".v..", "..v.", "...v" }, 19, 37, { v = moss.shade })
c:paint({ "v", "v", "v", "v" }, 34, 37, { v = dark.shade })
local t = c:save(O .. "aseprite/ph/stage-tuber-2.aseprite", O .. "png/ph/stage-tuber-2.png")
print(GV.report(t))
