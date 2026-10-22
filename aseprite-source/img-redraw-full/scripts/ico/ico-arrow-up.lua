local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local blue = GV.ramp("#3f93b2", { gloss = "#c8ecdc", shade = "#2f6290", deep = "#2a3c6c" })
local all = c:poly({ {32, 8}, {56, 32}, {42, 32}, {42, 57}, {22, 57}, {22, 32}, {8, 32} })
local head = c:poly({ {32, 8}, {56, 32}, {8, 32} })
local stem = c:rrect(22, 31, 41, 56, 2)

local p = c:build{
  { "stem", stem, blue, { light = all, gloss = { 26, 36 } } },
  { "head", head, blue, { light = all, gloss = { 22, 26 } } },
}
c:seam({ {32, 36}, {32, 52} })

local t = c:save(O .. "aseprite/ico/ico-arrow-up.aseprite", O .. "png/ico/ico-arrow-up.png")
print(GV.report(t))
