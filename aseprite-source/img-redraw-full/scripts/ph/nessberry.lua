local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local lite = GV.ramp("#7a5cc0", { gloss = "#a894dc" })
local dark = GV.ramp("#4e3a8a")
local stemR = GV.ramp("#4a8a3e")
-- forked stem: trunk then two arms and a short middle drop
local stem = c:line({ {32, 7}, {32, 11} }, 3)
stem:add(c:line({ {32, 11}, {27, 14}, {21, 19} }, 3))
stem:add(c:line({ {32, 11}, {37, 14}, {43, 19} }, 3))
stem:add(c:line({ {32, 11}, {32, 19} }, 2))
local leaf = c:poly({ {29, 10}, {24, 8}, {17, 7}, {11, 8}, {7, 11}, {11, 15}, {17, 16}, {24, 14} })
local function berry(x, y) return c:ellipse(x, y, 6, 6) end
c:build{
  { "leaf", leaf, "leaf", { cres = 2, deep = 1, gloss = false } },
  { "stem", stem, stemR, { flat = true } },
  { "b1", berry(20, 24), lite },
  { "b2", berry(32, 24), dark },
  { "b3", berry(44, 24), lite },
  { "b4", berry(26, 35), dark },
  { "b5", berry(38, 35), lite },
  { "b6", berry(32, 46), dark },
}
-- leaf vein
c:fill(c:line({ {26, 11}, {18, 11}, {10, 11} }, 1), "#4a8a3e")
-- loch shimmer: a little wave on the left berry
c:paint({ ".ss.", "s..s" }, 16, 27, { s = "#a894dc" })
local t = c:save(O .. "aseprite/ph/nessberry.aseprite", O .. "png/ph/nessberry.png")
print(GV.report(t))
