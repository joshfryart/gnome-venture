local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(25, 38, 17, 17)
body:add(c:ellipse(39, 45, 16, 9))
body:add(c:rrect(9, 40, 54, 53, 4))
body:cut(c:rect(0, 54, 63, 63))
local under = body:copy():clip(c:ellipse(32, 52, 24, 7))
local p = c:build{
  { "body", body, GV.ramp("#f08a24"), { gloss = { 16, 28 } } },
  { "under", under, GV.ramp("#e0501f"), { gloss = false } },
  { "dent", c:ellipse(43.5, 39, 5, 2), GV.ramp("#d6322b"), { gloss = false, contact = false } },
}
local fleck = { "#c9a96e" }
c:paint({ "cc.", ".cc" }, 17, 40, { c = "#c9a96e" })
c:paint({ "cc", "cc" }, 32, 30, { c = "#c9a96e" })
c:paint({ ".cc", "cc." }, 26, 46, { c = "#c9a96e" })
c:ground(32, 55, 22, 1.5)
local t = c:save(O .. "aseprite/ph/laterite-clay.aseprite", O .. "png/ph/laterite-clay.png")
print(GV.report(t))
