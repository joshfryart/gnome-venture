local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = c:rrect(15, 25, 48, 54, 7)
local fill = c:poly({ {18, 33}, {22, 31}, {26, 33}, {31, 30}, {36, 33}, {41, 31}, {46, 33}, {46, 52}, {18, 52} }):clip(glass:shrink(2))
local p = c:build{
  { "glass", glass, GV.ramp("#8fcbd8", { shade = "#5a86b8", deep = "#2f6290" }), { gloss = false } },
  { "pesto", fill, "moss", { gloss = false, rim = false } },
  { "label", c:rect(22, 37, 41, 47), "#f8eed2", { pale = true, gloss = false } },
  { "lid", c:rrect(19, 16, 44, 26, 2), "gold" },
}
-- glass shine streak on left
c:fill(c:rect(18, 29, 19, 32), "#c8ecdc"); c:px(18, 34, "#c8ecdc")
-- lid ridges
for x = 23, 41, 3 do c:px(x, 19, GV.R.gold.shade); c:px(x, 20, GV.R.gold.shade) end
c:seam({ {20, 24}, {43, 24} })
-- leaf icon on label
c:paint({
  "....ll",
  "...lml",
  "..lml.",
  ".lml..",
  "lml...",
  "ss....",
}, 29, 39, { l = "#4a8a3e", m = "#7ab55c", s = "#2f5a2a" })
local s = c:save(O .. "aseprite/ph/ramson-pesto.aseprite", O .. "png/ph/ramson-pesto.png")
print(GV.report(s))
