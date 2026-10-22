local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local grey = GV.ramp("#968f96")
c:build{
  { "page", c:rrect(15, 12, 49, 56, 3), GV.ramp("#f8eed2"), { pale = true } },
  { "bind", c:rrect(14, 8, 50, 18, 3), "wood" },
  { "l1", c:rect(21, 27, 43, 31), grey, { gloss = false } },
  { "l2", c:rect(21, 36, 43, 40), grey, { gloss = false } },
  { "l3", c:rect(21, 45, 35, 49), grey, { gloss = false } },
}
c:seam({ {17, 20}, {47, 20} })
local t = c:save(O .. "aseprite/ico/ico-notepad.aseprite", O .. "png/ico/ico-notepad.png")
print(GV.report(t))
