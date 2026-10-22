-- ph/garden-pond: blue oval of water in a grey stone ring, pale reed with a leaf curl
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local stone = GV.ramp("#968f96")
local reed = GV.ramp("#a9d6ea")

c:build{
  { "ring",  c:ellipse(31.5, 43, 26, 11), stone, { gloss = false } },
  { "water", c:ellipse(31.5, 41, 21, 7.5), "water", { gloss = { 18, 37 } } },
}
-- ripples (water carries the light)
c:fill(c:rect(22, 38, 27, 38), "#c8ecdc")
c:fill(c:rect(36, 43, 42, 43), "#8fcbd8")
c:fill(c:rect(17, 43, 21, 43), "#8fcbd8")
c:paint({ "r...r", ".rrr." }, 34, 37, { r = "#8fcbd8" })
-- stone cracks
c:paint({ "u.", ".u" }, 12, 46, { u = "umber" })
c:paint({ "u.", ".u", "u." }, 48, 49, { u = "umber" })
c:paint({ ".u", "u." }, 30, 52, { u = "umber" })
-- reed: stem and a leaf curl bending left
local stem = c:line({ { 33, 40 }, { 33, 15 } }, 3):add(c:line({ { 34, 12 }, { 34, 14 } }, 2))
local curl = c:line({ { 31, 33 }, { 28, 30 }, { 25, 26 }, { 23, 22 } }, 3):add(c:line({ { 24, 20 }, { 26, 18 }, { 28, 19 } }, 2))
c:part(stem:add(curl), reed, { flat = true })
c:px(33, 41, "#2f6290"); c:px(34, 41, "#2f6290"); c:px(35, 41, "#2f6290") -- tiny wet ring at the reed foot
c:ground(31.5, 55.5, 22, 2)

local t = c:save(O .. "aseprite/ph/garden-pond.aseprite", O .. "png/ph/garden-pond.png")
print(GV.report(t))
