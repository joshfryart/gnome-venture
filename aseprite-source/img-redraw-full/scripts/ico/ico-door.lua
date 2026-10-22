local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local slab = c:ellipse(32, 25, 18, 18):cut(c:rect(0, 26, 63, 63))
slab:add(c:rect(14, 25, 50, 56))
local strip = c:rect(29, 8, 34, 56):clip(slab:shrink(2))
local p = c:build{
  { "slab", slab, "wood" },
  { "strip", strip, GV.ramp("#d9a660"), { gloss = false } },
  { "knob", c:ellipse(42, 37, 4, 4), "gold" },
}
c:seam({ {31, 12}, {31, 54} })
c:seam({ {32, 12}, {32, 54} })
local t = c:save(O .. "aseprite/ico/ico-door.aseprite", O .. "png/ico/ico-door.png")
print(GV.report(t))
