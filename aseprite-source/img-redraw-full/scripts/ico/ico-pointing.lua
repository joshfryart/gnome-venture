local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local skin = GV.ramp("skin", { gloss = "#ffe2a8", shade = "#c47a52" })
local cuff = c:rrect(8, 21, 18, 51, 2)
local fist = c:rrect(16, 26, 42, 50, 8)
local finger = c:rrect(30, 24, 57, 35, 5)
local thumb = c:rrect(22, 17, 38, 28, 6)

local p = c:build{
  { "fist",   fist,   skin, { light = fist:copy():add(finger) } },
  { "finger", finger, skin },
  { "thumb",  thumb,  skin, { gloss = { 26, 20 } } },
  { "cuff",   cuff,   GV.ramp("#3f93b2"), { stitch = { side = "lit" } } },
}
-- curled finger creases on the fist
c:fill(c:line({ {29, 39}, {38, 39} }, 2), "#c47a52")
c:fill(c:line({ {29, 45}, {37, 45} }, 2), "#c47a52")
-- fingernail on the index tip
c:fill(c:rrect(50, 27, 54, 30, 1), "#f9d49c")
c:button(11, 33)

local t = c:save(O .. "aseprite/ico/ico-pointing.aseprite", O .. "png/ico/ico-pointing.png")
print(GV.report(t))
