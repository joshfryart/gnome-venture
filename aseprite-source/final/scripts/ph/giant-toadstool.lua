local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local stem = c:poly({ {24, 32}, {40, 32}, {44, 55}, {20, 55} }):add(c:ellipse(31.5, 53, 12, 3))
local lip = c:rrect(13, 28, 50, 34, 3)
local dome = c:ellipse(31.5, 31, 19.5, 14):cut(c:rect(0, 31, 63, 63))
local sprout = c:rect(31, 10, 33, 19)
local leafL = c:poly({ {32, 14}, {27, 8}, {21, 9}, {19, 13}, {24, 16}, {30, 16} })
local leafR = c:poly({ {32, 14}, {37, 8}, {43, 9}, {45, 13}, {40, 16}, {34, 16} })
local p = c:build{
  { "stem",   stem,   GV.ramp("#f1ece0") },
  { "lip",    lip,    GV.ramp("#b8452f") },
  { "dome",   dome,   GV.ramp("#e0501f"), { gloss = { 22, 22 } } },
  { "sprout", sprout, "moss", { flat = true } },
  { "leafL",  leafL,  GV.ramp("#58a03e"), { gloss = false } },
  { "leafR",  leafR,  GV.ramp("#6a9a3a"), { gloss = false } },
}
c:spot(c:ellipse(31.5, 24, 2.5, 1.5), "#f1ece0", "#fff3c8")
c:spot(c:ellipse(41, 26, 2, 1.5), "#f1ece0", "#fff3c8")
c:spot(c:ellipse(18.5, 28, 1.5, 1), "#f1ece0", "#fff3c8")
c:spot(c:ellipse(44.5, 20, 1, 1), "#f1ece0", "#fff3c8")
-- leaf veins
c:paint({ "v...", ".vv.", "...v" }, 23, 11, { v = "#2f5a2a" })
c:paint({ "...v", ".vv.", "v..." }, 37, 11, { v = "#2f5a2a" })
-- gill hints on stem top
c:paint({ "g.g.g.g.g" }, 24, 35, { g = "#c9a96e" })
c:ground(31.5, 57, 15, 1.5)
local t = c:save(O .. "aseprite/ph/giant-toadstool.aseprite", O .. "png/ph/giant-toadstool.png")
print(GV.report(t))
