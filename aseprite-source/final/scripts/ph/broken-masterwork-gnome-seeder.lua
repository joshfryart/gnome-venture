local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local legL = c:rect(14, 33, 19, 48)
local legR = c:rect(38, 33, 43, 48)
local footL = c:rrect(11, 46, 21, 50, 1)
local footR = c:rrect(36, 46, 46, 50, 1)
-- box with a chipped upper-left corner
local box = c:rrect(9, 18, 48, 35, 5)
box:cut(c:poly({ { 8, 17 }, { 16, 17 }, { 8, 25 } }))
local lid = c:rrect(11, 14, 46, 20, 2)
local crank = c:line({ { 48, 25 }, { 55, 19 } }, 4)
local hub = c:ellipse(48.5, 26.5, 3, 3)

c:build{
  { "legL", legL, GV.ramp("#b8661a") },
  { "legR", legR, GV.ramp("#b8661a") },
  { "footL", footL, "wood", { flat = true } },
  { "footR", footR, "wood", { flat = true } },
  { "crank", crank, GV.ramp("#b6814d", { rim = "#d9a660" }), { flat = true } },
  { "box", box, "gold", { gloss = { 13, 23 } } },
  { "lid", lid, GV.ramp("#d0862a"), { gloss = false } },
  { "hub", hub, "wood", { flat = true } },
}
-- seed port
c:fill(c:ellipse(29, 27, 5, 5), "#b07a10")
c:fill(c:ellipse(29, 27, 3, 3), "#7a3a14")
c:px(27, 25, "#d0862a")
-- jagged snapped tip of the crank
c:paint({
  "o.o",
  "ooo",
}, 54, 16, { o = "#2a1a10" })
-- crack zig-zag down the box (right of the port)
c:paint({
  "kk..",
  ".kk.",
  "..kk",
  ".kk.",
  "kk..",
  ".kk.",
  "..kk",
  ".kk.",
  "kk..",
  ".kk.",
}, 37, 21, { k = "#2a1a10" })
-- seed hopper rivets
c:px(14, 16, "#f5cf6a"); c:px(43, 16, "#f5cf6a")
-- loose chip fallen beside
c:part(c:poly({ { 49, 49 }, { 54, 49 }, { 51, 45 } }), "gold", { flat = true })
c:ground(29, 50, 20, 1.5)

local t = c:save(O .. "aseprite/ph/broken-masterwork-gnome-seeder.aseprite", O .. "png/ph/broken-masterwork-gnome-seeder.png")
print(GV.report(t))
