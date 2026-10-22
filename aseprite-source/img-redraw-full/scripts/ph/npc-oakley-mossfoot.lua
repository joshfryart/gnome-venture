local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }
local tan  = GV.ramp("#dcb06a")
local pale = GV.ramp("#e6f1ec")
local brown = GV.ramp("#a5663a", { shade = "#8c4a1a" })
local purple = GV.ramp("#7a5cc0")
local blue = GV.ramp("#3f93b2")
local green = GV.ramp("#2e5a2c")

local disc = c:ellipse(40, 58, 25, 25)
-- wings: upper pair longer, lower pair shorter, 3px gap between
local wUL = c:ellipse(16, 46, 11, 5.5)
local wUR = c:ellipse(63, 46, 11, 5.5)
local wLL = c:ellipse(18.5, 61, 10.5, 4.5)
local wLR = c:ellipse(60.5, 61, 10.5, 4.5)
local wings = wUL:copy(); wings:add(wUR); wings:add(wLL); wings:add(wLR)

local body = c:ellipse(39.5, 101, 31.5, 23)
local scarf = c:line({ {28, 78}, {40, 83}, {52, 78} }, 5)
local tail = c:poly({ {46, 81}, {52, 81}, {53, 94}, {45, 94} })
local head = c:ellipse(39.5, 58, 15.5, 16)
local domeL = c:ellipse(27, 47, 10, 10)
local domeR = c:ellipse(53, 47, 10, 10)
local inL = c:ellipse(26, 46, 7, 7)
local inR = c:ellipse(52, 46, 7, 7)
local crown = c:ellipse(39.5, 33, 15.5, 14):cut(c:rect(0, 33, 79, 99))
local band = c:rect(24, 27, 55, 31):clip(crown)
local brim = c:ellipse(39.5, 35, 33.5, 4)

local p = c:build{

  { "wings", wings, pale, { light = wings } },
  { "body", body, brown, { stitch = { side = "lit" } } },
  { "scarf", scarf, purple },
  { "tail", tail, purple, { gloss = false } },
  { "head", head, blue },
  { "domes", domeL:copy():add(domeR), green, { gloss = false } },
  { "inner", inL:copy():add(inR), "moss" },
  { "crown", crown, "gold" },
  { "band", band, purple, { flat = true } },
  { "brim", brim, tan },
}
-- wing veins
c:paint({ "vvvvvvvvvvvvv" }, 10, 47, { v = "#c8ecdc" })
c:paint({ "vvvvvvvvvvvvv" }, 57, 47, { v = "#c8ecdc" })
c:paint({ "vvvvvvvvvvv" }, 13, 61, { v = "#c8ecdc" })
c:paint({ "vvvvvvvvvvv" }, 56, 61, { v = "#c8ecdc" })
c:eye(24, 45); c:eye(50, 45)
c:paint({ "m.........m", ".m.......m.", "..mmmmmmm.." }, 34, 64, { m = "#2a1a10" })
c:seam({ {10, 37}, {24, 38}, {40, 39}, {56, 38}, {70, 37} })
c:seam({ {46, 92}, {53, 92} })
c:button(37, 79)
local t = c:save(O .. "aseprite/ph/npc-oakley-mossfoot.aseprite", O .. "png/ph/npc-oakley-mossfoot.png")
print(GV.report(t))
