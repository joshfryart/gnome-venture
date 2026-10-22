local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local W = GV.R.wood
local p = c:build{
  { "crate", c:rrect(13, 14, 51, 56, 4), "wood" },
  { "frame", c:rrect(17, 25, 47, 46, 5), GV.ramp("#8c4a1a"), { gloss = false } },
  { "window", c:rrect(19, 27, 45, 44, 4), GV.ramp("#f4f0e0"), { gloss = false } },
  { "nut", c:ellipse(32, 38.5, 7, 5.5), GV.ramp("#8c4a1a"), { gloss = { 28, 35 } } },
  { "stem", c:line({ {32, 33}, {32, 29} }, 2), "#2e5a2c", { flat = true } },
  { "leaf", c:ellipse(35.5, 29, 2.5, 1.5), GV.ramp("#58a03e"), { flat = true } },
}
-- cap line across the nut top
c:paint({ "..ccccc..", ".c.....c." }, 28, 35, { c = "#44281c" })
-- plank gaps (top and bottom bands)
c:fill(c:rect(15, 22, 49, 23), W.shade)
c:fill(c:rect(15, 48, 49, 49), W.shade)
c:fill(c:rect(24, 15, 24, 21), W.shade); c:fill(c:rect(40, 15, 40, 21), W.shade)
c:fill(c:rect(24, 50, 24, 54), W.shade); c:fill(c:rect(40, 50, 40, 54), W.shade)
-- nails
for _, x in ipairs({ 18, 32, 45 }) do c:fill(c:rect(x, 51, x + 1, 52), "#5e2f1e") end
for _, x in ipairs({ 18, 45 }) do c:fill(c:rect(x, 17, x + 1, 18), "#5e2f1e") end
c:seam({ {21, 19}, {38, 19} })

local t = c:save(O .. "aseprite/ph/brazil-nut-seed.aseprite", O .. "png/ph/brazil-nut-seed.png")
print(GV.report(t))
