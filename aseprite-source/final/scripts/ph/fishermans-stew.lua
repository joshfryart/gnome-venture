local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local potR = GV.ramp("#8b8f96", { shade = "#5b6470" })
local darkR = GV.ramp("#6a6070")
-- deep rounded cauldron
local body = c:rect(11, 22, 52, 34)
body:add(c:ellipse(31.5, 33, 21, 15):cut(c:rect(0, 0, 63, 27)))
body:cut(c:rect(0, 49, 63, 63))
-- horizontal side lugs
local lugs = c:rrect(6, 22, 12, 26, 1):add(c:rrect(51, 22, 57, 26, 1))
local rim = c:ellipse(31.5, 22, 21, 6)
local broth = c:ellipse(31.5, 22, 17, 3.5)
local fish = c:ellipse(25, 21.5, 3, 2)
local herb = c:ellipse(38, 22, 2.5, 1.5)
local p = c:build{
  { "lugs", lugs, darkR, { gloss = false } },
  { "pot", body, potR, { gloss = { 20, 31 } } },
  { "rim", rim, darkR, { gloss = false } },
  { "broth", broth, "gold", { gloss = { 22, 20 } } },
  { "fish", fish, "#e8d0b0", { flat = true } },
  { "herb", herb, "moss", { flat = true } },
}
c:px(26, 21, "#c49870"); c:px(24, 22, "#c49870")
c:px(39, 21, "#2f5a2a"); c:px(37, 23, "#2f5a2a")
c:px(44, 22, "#7ab55c"); c:px(45, 21, "#7ab55c")
-- lug holes
c:paint({ "hh" }, 8, 24, { h = "#3a3440" }); c:paint({ "hh" }, 54, 24, { h = "#3a3440" })
c:ground(31.5, 54, 19, 2.5)
local t = c:save(O .. "aseprite/ph/fishermans-stew.aseprite", O .. "png/ph/fishermans-stew.png")
print(GV.report(t))
