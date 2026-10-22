local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(31.5, 38, 18, 17)
local crown = c:rect(23, 17, 40, 23)
crown:add(c:poly({ {22,18}, {21,8}, {28,18} }))
crown:add(c:poly({ {28,18}, {31.5,5}, {36,18} }))
crown:add(c:poly({ {35,18}, {42,8}, {41,18} }))
local p = c:build{
  { "crown", crown, GV.ramp("#ae2a2a") },
  { "body", body, "red" },
}
-- split showing seeds
local split = c:poly({ {37,41}, {42,38}, {48,40}, {47,46}, {41,48}, {36,45} })
c:fill(split, "#6b1b2c")
c:paint({ "rr.", "rr.", "..." }, 39, 41, { r = "#ff9158" })
c:paint({ "rr", "rr" }, 43, 40, { r = "#f2793a" })
c:paint({ "rr", "rr" }, 42, 44, { r = "#ff9158" })
c:px(39, 41, "#ffc27a"); c:px(42, 44, "#ffc27a")
local t = c:save(O .. "aseprite/ph/pomegranate.aseprite", O .. "png/ph/pomegranate.png")
print(GV.report(t))
