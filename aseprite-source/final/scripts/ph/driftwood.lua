-- ph/driftwood : weathered log on its side with a pale ringed cut end
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local bark = GV.ramp("#8a4f2a")
-- log body, slightly knobbly: main rounded bar plus a broken snag on top
local log = c:rrect(9, 23, 52, 45, 10)
log:add(c:poly({ {20, 24}, {23, 18}, {27, 18}, {28, 24} }))
local face = c:ellipse(48, 34, 7, 11)

c:build{
  { "log", log, bark, { gloss = { 16, 28 } } },
  { "face", face, GV.ramp("#e2bd7a"), { gloss = { 45, 27 }, rim = false } },
}
-- growth rings
local function ring(rx, ry, hex)
  local o = c:ellipse(48, 34, rx, ry)
  c:fill(o:cut(c:ellipse(48, 34, rx - 1, ry - 1)), hex)
end
ring(5, 8, "#b07a45")
ring(2.5, 4, "#b07a45")
c:px(48, 34, "#8a4f2a")
-- grain streaks along the bark
c:fill(c:line({ {15, 31}, {24, 31}, {35, 30} }, 2):clip(log:shrink(2)), "#5e2f1e")
c:fill(c:line({ {13, 39}, {26, 40}, {37, 39} }, 2):clip(log:shrink(2)), "#5e2f1e")
c:fill(c:line({ {29, 35}, {37, 35} }, 1):clip(log:shrink(2)), "#5e2f1e")
-- weathered knot
c:paint({ ".k.", "kdk", ".k." }, 31, 25, { k = "#5e2f1e", d = "#3d2a1c" })
c:ground(31, 47, 20, 1.5)

local t = c:save(O .. "aseprite/ph/driftwood.aseprite", O .. "png/ph/driftwood.png")
print(GV.report(t))
