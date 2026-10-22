local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- handle: diagonal shaft, split lengthwise
local handle = c:line({ {33, 22}, {46, 52} }, 7)
-- head: arched crescent, pointed left tip, chipped right tip
local head = c:ellipse(32, 27, 24, 16):cut(c:ellipse(32, 34, 20, 15)):cut(c:rect(0, 27, 63, 63))
head:cut(c:poly({ {51, 28}, {58, 20}, {60, 28} }))         -- missing chip at right tip
local chip = c:poly({ {53, 34}, {58, 32}, {57, 37} })       -- loose piece, fallen below the tip

c:build{
  { "handle", handle, "wood" },
  { "head", head, "#8c4a1a" },
  { "chip", chip, "#8c4a1a", { flat = true } },
}
-- crack across the head band
c:paint({
  "x..",
  ".x.",
  ".x.",
  "x..",
  ".x.",
}, 29, 12, { x = "#2a1a10" })
-- lengthwise split along the handle
c:paint({
  "x...",
  ".x..",
  ".x..",
  "..x.",
  "..x.",
  ".x..",
  "..x.",
  "...x",
  "...x",
  "..x.",
  "...x",
}, 35, 30, { x = "#2a1a10" })

local t = c:save(O .. "aseprite/ph/broken-rock-pick.aseprite", O .. "png/ph/broken-rock-pick.png")
print(GV.report(t))
