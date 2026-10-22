local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = c:rrect(17, 21, 46, 54, 8)
glass:add(c:rrect(20, 19, 43, 26, 2))
local beets = c:rrect(19, 31, 44, 52, 6)
beets:add(c:rect(19, 31, 44, 36))
local p = c:build{
  { "glass", glass, GV.ramp("#a9d6ea"), { gloss = { 22, 27 } } },
  { "beets", beets, GV.ramp("#7a5cc0"), { gloss = false } },
  { "label", c:rrect(22, 37, 41, 46, 1), "cream" },
  { "lid", c:rrect(17, 13, 46, 23, 4), "gold" },
}
c:seam({ {19, 21}, {45, 21} })
-- wave glints in beets
c:paint({ ".ww..ww..", "w..ww..ww" }, 23, 32, { w = "#c8ecdc" })
c:paint({ "ww..ww..ww", "..ww..ww.." }, 31, 48, { w = "#c8ecdc" })
-- beet emblem on label
c:paint({
  "...gg...",
  "..pppp..",
  ".pppppp.",
  ".pppppp.",
  "..pppp..",
  "...pp...",
}, 28, 39, { g = "#4a8a3e", p = "#7a2c6a" })
c:px(30, 41, "#b25aa0")
local t = c:save(O .. "aseprite/ph/pickled-beets.aseprite", O .. "png/ph/pickled-beets.png")
print(GV.report(t))
