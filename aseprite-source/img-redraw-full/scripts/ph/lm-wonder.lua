local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local stone = GV.ramp("#8b8f96")
local dark = GV.ramp("#6a6070")
local mound = c:ellipse(31.5, 52, 25, 6):cut(c:rect(0, 57, 63, 63))
mound:add(c:rrect(9, 50, 54, 56, 3))
-- four-point star
local star = c:poly({ {32,25}, {35,35}, {45,38}, {35,41}, {32,51}, {29,41}, {19,38}, {29,35} })
star:add(c:rect(29, 35, 34, 40))
local p = c:build{
  { "mound", mound, GV.ramp("#58a03e") },
  { "lpil", c:rrect(13, 22, 21, 53, 2), stone },
  { "rpil", c:rrect(42, 22, 50, 53, 2), stone },
  { "lintel", c:rrect(6, 13, 57, 24, 4), dark },
  { "star", star, "gold" },
}
-- pillar base blocks for a gate feel
c:seam({ {8, 24}, {55, 24} })
c:button(30, 15)
-- stone block lines on pillars
for _, x in ipairs({ 12, 41 }) do
  c:fill(c:rect(x + 2, 38, x + 8, 38), stone.shade)
end
-- sparkles (small four-point)
local function sparkle(x, y)
  c:paint({ ".g.", "gwg", ".g." }, x - 1, y - 1, { g = "#f5cf6a", w = "#fff1c8" })
end
sparkle(25, 29); sparkle(39, 46); sparkle(25, 47)
local t = c:save(O .. "aseprite/ph/lm-wonder.aseprite", O .. "png/ph/lm-wonder.png")
print(GV.report(t))
