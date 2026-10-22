local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local silver = GV.ramp("#a38f80")
-- body: tapered spindle, blunt nose at left
local body = c:ellipse(24, 33, 15, 9)
body:add(c:poly({ {34, 28}, {44, 31}, {44, 37}, {34, 39} }))
-- swallow tail
body:add(c:poly({ {42, 31}, {50, 20}, {54, 21}, {50, 34}, {54, 46}, {50, 47}, {42, 37} }))
local fin1 = c:poly({ {16, 27}, {21, 14}, {28, 26} })
local fin2 = c:poly({ {28, 27}, {35, 18}, {39, 31} })
local pelv = c:poly({ {25, 40}, {31, 48}, {34, 40} })
local plate = c:poly({ {19, 35}, {33, 33}, {34, 39}, {21, 41} })
local p = c:build{
  { "fin1", fin1, "#3f93b2" },
  { "fin2", fin2, "#3f93b2" },
  { "pelv", pelv, "#3f93b2", { flat = true } },
  { "body", body, silver },
  { "plate", plate, "#f8eed2", { pale = true, gloss = false } },
}
-- scale lines on belly plate
c:paint({ "s....s....s", ".s....s....s" }, 22, 37, { s = "#a38f80" })
-- gill arc behind the eye
c:paint({ ".g", "g.", "g.", "g.", ".g" }, 17, 30, { g = "#2a1a10" })
c:seam({ {22, 26}, {34, 27}, {42, 31} })
c:eye(11, 31, true)
c:paint({ ".k.", "kkk", ".k." }, 47, 24, { k = "#b8d8d2" })
local t = c:save(O .. "aseprite/ph/creature-silverfin.aseprite", O .. "png/ph/creature-silverfin.png")
print(GV.report(t))
