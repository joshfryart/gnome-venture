local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local terra = GV.ramp("#c0693a")
local belly = c:ellipse(31.5, 38, 20, 18)
local neck = c:rect(23, 14, 40, 26)
local lip = c:rrect(17, 8, 46, 16, 2)
local band = c:rect(12, 34, 51, 39):clip(belly)
local p = c:build{
  { "belly", belly:copy():add(neck), terra, { gloss = { 18, 28 } } },
  { "lip",   lip,  "wood" },
  { "band",  band, GV.ramp("#dcb06a"), { gloss = false } },
}
c:fill(c:rrect(21, 8, 42, 10, 1), "#7a4a1f")
c:fill(c:rect(23, 8, 40, 8), "#3d2a1c")
-- trowel emblem
c:part(c:rect(30, 41, 33, 44), "wood", { flat = true })
c:part(c:poly({ {27, 45}, {37, 45}, {32, 55} }), "stone", { gloss = { 29, 46 }, contact = false })
c:seam({ {14, 34}, {50, 34} })
local t = c:save(O .. "aseprite/ico/ico-trowel-pot.aseprite", O .. "png/ico/ico-trowel-pot.png")
print(GV.report(t))
