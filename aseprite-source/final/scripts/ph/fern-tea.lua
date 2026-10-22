local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local jar = c:poly({ {16, 19}, {48, 19}, {45, 51}, {19, 51} })
local lid = c:rrect(13, 12, 50, 21, 3)
local label = c:rrect(24, 30, 39, 41, 3)
local p = c:build{
  { "jar", jar, GV.ramp("#58a03e", { bounce = "#6a9a3a", deep = "#2f5a2a" }) },
  { "lid", lid, GV.ramp("#c4925f", { rim = "#f0d49a" }) },
  { "label", label, "cream", { gloss = false, cres = 2, deep = 1 } },
}
-- fern squiggle on the label
c:paint({
  "...f....",
  ".f.f.f..",
  "..fff...",
  "f..f..f.",
  ".f.f.f..",
  "..fff...",
  "...f....",
  "...f....",
}, 28, 32, { f = "#2f5a2a" })
c:seam({ {14, 21}, {49, 21} })
c:button(30, 14)
c:ground(32, 53, 16, 2)
local t = c:save(O .. "aseprite/ph/fern-tea.aseprite", O .. "png/ph/fern-tea.png")
print(GV.report(t))
