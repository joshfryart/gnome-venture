local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- ring handle: outer ellipse minus inner, top half only
local ring = c:ellipse(31.5, 13, 9, 8):cut(c:ellipse(31.5, 13, 6, 5)):cut(c:rect(0, 15, 63, 63))
local topcap = c:rrect(19, 15, 44, 21, 2)
topcap:add(c:rrect(23, 12, 40, 16, 2))
local glass = c:rrect(22, 21, 41, 47, 4)
local botcap = c:rrect(19, 47, 44, 54, 2)

local p = c:build{
  { "handle", ring, "stone", { flat = true } },
  { "glass", glass, GV.ramp("#f5cf6a"), { gloss = { 28, 24 }, cres = 3, deep = 1 } },
  { "top", topcap, "stone" },
  { "bot", botcap, GV.ramp("#5b6470") },
}

-- flame disc
local flame = c:ellipse(31.5, 35, 6, 7)
local tip = c:poly({ {29, 30}, {31, 23}, {32, 23}, {35, 30} })
flame:add(tip)
c:part(flame, GV.ramp("#f08a24"), { gloss = false, contact = false })
c:fill(c:ellipse(31.5, 37, 3, 4), "#f5cf6a")
c:fill(c:rect(31, 35, 32, 38), "#fff1c8")

-- cage bars
c:fill(c:rect(25, 22, 25, 46), "#5b6470")
c:fill(c:rect(38, 22, 38, 46), "#5b6470")



c:seam({ {20, 19}, {43, 19} })

c:ground(31.5, 56, 14, 1.5)
local t = c:save(O .. "aseprite/ph/miner-s-lantern.aseprite", O .. "png/ph/miner-s-lantern.png")
print(GV.report(t))
