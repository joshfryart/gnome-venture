local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- low wide lumpy pebble, flat-ish bottom
local body = c:ellipse(31.5, 38, 23, 14)
body:add(c:ellipse(25, 33, 13, 10))
body:add(c:ellipse(40, 37, 14, 11))
body:add(c:rrect(9, 40, 54, 52, 6))
body:cut(c:rect(0, 53, 63, 63))
local lip = c:ellipse(32, 46, 21, 7):cut(c:ellipse(32, 42, 22, 7)):clip(body:shrink(2))
lip:cut(c:rect(0, 0, 63, 44))
local p = c:build{
  { "body", body, GV.ramp("#aaa2b4", { shade = "#7e7590", deep = "#564a6c" }), { gloss = false, cres = 3, deep = 1 } },
  { "lip",  lip,  GV.ramp("#6a6070"), { gloss = false, rim = false } },
}
-- glint streaks + big gloss comma
for x = 17, 30 do c:px(x, 28, "#fff3c8") end
for x = 15, 20 do c:px(x, 33, "#fff3c8") end
c:paint({ "ggg.", "gg..", "g..." }, 20, 30, { g = "#fff3c8" })
c:px(31, 27, "#fff3c8")
c:px(24, 32, "#ffffff")
c:ground(32, 56, 17, 2, "#c9a96e")
local t = c:save(O .. "aseprite/ph/desert-glass.aseprite", O .. "png/ph/desert-glass.png")
print(GV.report(t))
