local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/"
local GV = dofile(D .. "gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local R = GV.R
local body = c:ellipse(32, 33, 13, 11):add(c:ellipse(32, 41, 10, 10)):add(c:rrect(20, 22, 44, 30, 6))
local leafL = c:poly({ {32,25},{27,20},{24,15},{24,11},{28,12},{31,15},{34,22} })
local leafR = c:poly({ {31,25},{36,20},{39,15},{40,10},{36,11},{33,15},{30,22} })
c:build{
  { "leafL", leafL, GV.ramp("#58a03e"), { gloss = false } },
  { "leafR", leafR, GV.ramp("#58a03e"), { gloss = false } },
  { "body", body, GV.ramp("#dcb06a", { shade = "#c08a48" , deep = "#a8582f" }), { pale = true, gloss = { 25, 28 } } },
}
c:paint({ "ddd" }, 24, 33, { d = "#2a1a10" })
c:paint({ "ddd" }, 35, 42, { d = "#2a1a10" })
local t = c:save(O .. "aseprite/ico/ico-potato.aseprite", O .. "png/ico/ico-potato.png")
print("ico-potato " .. GV.report(t))
