local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local trunk = c:rrect(28, 36, 36, 52, 2)
trunk:add(c:poly({ {28, 46}, {36, 46}, {39, 54}, {25, 54} }))
local crown = c:ellipse(32, 28, 17, 16)
local llobe = c:ellipse(22, 33, 9, 8)
local urlobe = c:ellipse(44, 19, 8, 7.5)
local all = crown:copy(); all:add(llobe); all:add(urlobe)

local p = c:build{
  { "trunk", trunk, "wood", { gloss = false } },
  { "ur", urlobe, GV.ramp("#2f5a2a"), { gloss = false } },
  { "crown", crown, GV.ramp("#58a03e"), { light = all } },
  { "ll", llobe, "moss", { gloss = { 18, 29 } } },
}
-- trunk knot
c:paint({ ".kk.", "k..k", ".kk." }, 30, 48, { k = GV.R.wood.deep })
c:px(31, 49, GV.R.wood.shade); c:px(32, 49, GV.R.wood.shade)
-- leaf nicks on the lower left
c:line({ {17, 37}, {19, 38}, {21, 38} }, 1)
c:paint({ "nn...", "..nnn" }, 16, 36, { n = "#2f5a2a" })
c:paint({ "nn...", "..nnn" }, 21, 39, { n = "#2f5a2a" })
c:paint({ "nnn..", "...nn" }, 36, 38, { n = "#3d7a2c" })
c:ground(32, 55, 15, 2, "#6a4528")

local t = c:save(O .. "aseprite/ph/garden-oak.aseprite", O .. "png/ph/garden-oak.png")
print(GV.report(t))
