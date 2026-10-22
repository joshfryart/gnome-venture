local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- handle snapped in two: upper stub and lower piece, jagged break
local up = c:line({ {32, 18}, {36, 30} }, 6)
up:add(c:rect(34, 31, 35, 32)); up:add(c:rect(37, 30, 38, 31))
local lo = c:line({ {39, 36}, {45, 50} }, 6)
lo:add(c:rect(38, 34, 39, 35)); lo:add(c:rect(41, 33, 42, 35))
-- crescent pick head
local head = c:ellipse(31.5, 30, 23, 19):cut(c:ellipse(31.5, 37, 20, 19)):cut(c:rect(0, 29, 63, 63))
-- loose chips
local chip1 = c:poly({ {12, 46}, {16, 45}, {15, 49}, {11, 49} })
local chip2 = c:poly({ {22, 50}, {26, 49}, {27, 52}, {22, 53} })

local p = c:build{
  { "lo", lo, "wood" },
  { "up", up, "wood" },
  { "head", head, GV.ramp("#8c4a1a", { gloss = "#ecc58a" }) },
  { "chip1", chip1, "wood", { flat = true } },
  { "chip2", chip2, "wood", { flat = true } },
}
-- crack through the head
c:fill(c:line({ {30, 13}, {32, 15}, {30, 17}, {32, 19} }, 1), "#2a1a10")
c:fill(c:line({ {31, 13}, {33, 15}, {31, 17}, {33, 19} }, 1), "#2a1a10")
-- splinters at the snap
c:paint({ "d.d.d" }, 32, 30, { d = "#2a1a10" })
c:paint({ "l..l" }, 38, 36, { l = "#d9a660" })
-- ferrule band where handle meets head
c:fill(c:rect(31, 21, 36, 21), "#5e2f1e")
local t = c:save(O .. "aseprite/ph/broken-prospector-s-pick.aseprite", O .. "png/ph/broken-prospector-s-pick.png")
print(GV.report(t))
