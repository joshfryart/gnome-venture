local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = c:poly({ {16, 14}, {49, 14}, {45, 54}, {20, 54} })
local inner = glass:shrink(2)
local liquid = inner:copy():clip(c:rect(0, 20, 63, 38))
local sed = inner:copy():clip(c:rect(0, 38, 63, 51))
local p = c:build{
  { "glass", glass, GV.ramp("#a9d6ea", { rim = "#8fcbd8" }) },
  { "tea", liquid, GV.ramp("#5aa8cc"), { gloss = false } },
  { "sed", sed, GV.ramp("#8c4a1a"), { gloss = false } },
}
-- foam wave at boundary
c:paint({ ".ff..ff..ff..ff..ff..ff..ff..", "f..ff..ff..ff..ff..ff..ff..ff" }, 18, 37, { f = "#f4f0e0" })
-- sediment specks
c:paint({ "d...d....d..d...d" }, 23, 44, { d = "#5e2f1e" })
c:paint({ "..d....d....d...." }, 23, 48, { d = "#5e2f1e" })
-- rim line
c:fill(c:rect(17, 14, 47, 15), "#c8ecdc")
c:fill(c:rect(17, 16, 47, 16), "#8fcbd8")
-- glass gloss streak on left wall
c:fill(c:line({ {20, 21}, {21, 31} }, 1), "#e6f6f0")
c:px(20, 34, "#e6f6f0")
c:ground(32.5, 55, 13, 1.5)
local t = c:save(O .. "aseprite/ph/worm-tea.aseprite", O .. "png/ph/worm-tea.png")
print(GV.report(t))
