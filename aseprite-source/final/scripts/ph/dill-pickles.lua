local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = GV.ramp("#a9d6ea", { rim = "#8fcbd8" })
local p = c:build{
  { "jar", c:rrect(17, 21, 46, 56, 7), glass },
  { "brine", c:rrect(20, 29, 43, 53, 5), GV.ramp("#7ab55c"), { gloss = false } },
  { "pk1", c:ellipse(26.5, 39, 3.5, 9), GV.ramp("#4a8a3e"), { gloss = false } },
  { "pk2", c:ellipse(36.5, 40, 3.5, 9), GV.ramp("#4a8a3e"), { gloss = false } },
  { "label", c:rect(21, 41, 42, 49), GV.ramp("#f1ece0") },
  { "lid", c:rrect(16, 12, 47, 22, 4), "gold" },
}
-- pickle bumps
c:px(25, 34, "#2f5a2a"); c:px(27, 38, "#2f5a2a"); c:px(35, 35, "#2f5a2a"); c:px(37, 38, "#2f5a2a")
-- dill specks
c:px(22, 32, "#c8d77a"); c:px(31, 31, "#c8d77a"); c:px(41, 34, "#c8d77a")
-- sprig on label
c:paint({
  "..g.g..",
  "g.ggg.g",
  ".ggggg.",
  "...g...",
  "...g...",
}, 28, 43, { g = "#4a8a3e" })
-- lid ridges
for x = 22, 42, 4 do c:px(x, 19, "#b8661a"); c:px(x, 20, "#b8661a") end
c:seam({ {18, 22}, {46, 22} }, { free = true })
c:button(19, 14)
local t = c:save(O .. "aseprite/ph/dill-pickles.aseprite", O .. "png/ph/dill-pickles.png")
print(GV.report(t))
