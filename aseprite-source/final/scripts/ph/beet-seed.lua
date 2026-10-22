local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local lid = c:ellipse(31.5, 25, 18.5, 9):cut(c:rect(0, 26, 63, 63))
local beet = c:ellipse(31.5, 35, 7, 6):add(c:poly({ {25,37}, {39,37}, {32,47} }))
local leafL = c:poly({ {29,30}, {24,24}, {23,26}, {27,31} })
local leafR = c:poly({ {34,30}, {39,24}, {41,26}, {36,31} })
c:build{
  { "pot",    c:rrect(12, 23, 51, 52, 13), GV.ramp("#f1ece0") },
  { "lid",    lid, GV.ramp("#dcb06a") },
  { "knob",   c:rrect(29, 11, 34, 17, 2), "gold", { flat = true } },
  { "frame",  c:rrect(18, 29, 45, 49, 5), GV.ramp("#7a5cc0"), { flat = true, contact = false } },
  { "label",  c:rrect(20, 31, 43, 47, 4), GV.ramp("#f4f0e0"), { flat = true, rim = false, contact = false } },
  { "leafL",  leafL, GV.ramp("#58a03e"), { flat = true } },
  { "leafR",  leafR, GV.ramp("#58a03e"), { flat = true } },
  { "beet",   beet, GV.ramp("#7a5cc0") },
}
c:paint({ "s...", ".s..", "..s." }, 28, 38, { s = "#4e3a8a" })
c:paint({ "..s", ".s." }, 34, 41, { s = "#4e3a8a" })
c:seam({ {15, 25}, {48, 25} })
c:button(30, 12)
c:fill(c:rect(25, 50, 26, 50), "#8c4a1a")
c:fill(c:rect(31, 50, 32, 50), "#8c4a1a")
c:fill(c:rect(37, 50, 38, 50), "#8c4a1a")
c:ground(31.5, 54, 17, 1.5)
local t = c:save(O .. "aseprite/ph/beet-seed.aseprite", O .. "png/ph/beet-seed.png")
print(GV.report(t))
