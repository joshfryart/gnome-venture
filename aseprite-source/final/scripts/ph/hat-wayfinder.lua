local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local crown = c:poly({ {13,47},{14,32},{18,22},{26,14},{35,9},{44,8},{50,10},{50,15},{44,15},{40,19},{45,28},{48,38},{51,47} })
local brim = c:ellipse(32, 48, 25, 6.5)
local band = c:rrect(13, 39, 51, 46, 3)

local p = c:build{
  { "brim", brim, GV.ramp("#2f5a2a"), { gloss = false } },
  { "crown", crown, "moss", { gloss = { 22, 21 }, stitch = { side = "lit" } } },
  { "band", band, GV.ramp("#3e6e30"), { gloss = false } },
  { "badge", c:ellipse(31.5, 30.5, 7.5, 7.5), "cream", { gloss = { 27, 26 } } },
  { "bobble", c:ellipse(50.5, 12.5, 4, 4), "gold" },
}

-- compass needle: red diamond pointing up, dark tail
c:paint({
  "..r..",
  "..r..",
  ".rrr.",
  ".rrr.",
  "rrrrr",
  "ddkdd",
  ".ddd.",
  ".ddd.",
  "..d..",
  "..d..",
}, 29, 26, { r = "#dd3a2a", d = "#6b1b2c", k = "#2a1a10" })
-- tick marks N E S W
c:px(31, 24, "#8a4f2a"); c:px(38, 30, "#8a4f2a"); c:px(25, 30, "#8a4f2a"); c:px(31, 37, "#8a4f2a")

c:seam({ {15, 40}, {49, 40} })
c:button(46, 41)
c:ground(32, 56, 25, 2)
local t = c:save(O .. "aseprite/ph/hat-wayfinder.aseprite", O .. "png/ph/hat-wayfinder.png")
print(GV.report(t))
