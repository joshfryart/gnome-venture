local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local full = c:ellipse(31.5, 36, 17, 16)
local belly = full:copy():clip(c:rect(0, 42, 63, 63))
local top = full:copy():cut(c:rect(0, 42, 63, 63))
local stem = c:rrect(30, 13, 33, 22, 1)
local leaf = c:poly({ {33, 20}, {35, 13}, {39, 8}, {45, 5}, {45, 10}, {42, 16}, {37, 20} })
local p = c:build{
  { "stem", stem, "wood", { flat = true } },
  { "top", top, "moss", { light = full, gloss = { 24, 27 } } },
  { "belly", belly, GV.ramp("#f5cf6a", { shade = "#e8a317", deep = "#b8661a", bounce = "#d0862a" }), { light = full, gloss = false, contour = false } },
  { "leaf", leaf, "leaf" },
}
-- hard sunrise edge: thin orange band at very bottom already via shade; add a mid band line
c:fill(c:line({ {38, 7}, {35, 12}, {34, 18} }, 1), "#7ab55c")
-- peel dots
c:px(36, 26, "#4a8a3e"); c:px(41, 33, "#4a8a3e"); c:px(28, 36, "#4a8a3e"); c:px(22, 38, "#4a8a3e")
-- sunrise glints on belly
c:px(22, 44, "#fff1c8"); c:px(23, 44, "#fff1c8")
local t = c:save(O .. "aseprite/ph/sunrise-lime.aseprite", O .. "png/ph/sunrise-lime.png")
print(GV.report(t))
