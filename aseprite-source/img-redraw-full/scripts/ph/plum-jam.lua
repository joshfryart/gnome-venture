local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- squat round jar, wide lid
local glass = c:rrect(15, 23, 48, 55, 10)
glass:add(c:rrect(19, 21, 44, 28, 2))
local jam = c:rrect(17, 27, 46, 54, 9)
local lid = c:rrect(14, 11, 49, 24, 4)
local p = c:build{
  { "glass", glass, "glass" },
  { "jam", jam, GV.ramp("#7b66b4", { shade = "#3e2f66", deep = "#291d4a" }), { light = glass } },
  { "lid", lid, "gold" },
  { "label", c:rrect(23, 36, 40, 46, 1), "cream", { gloss = false } },
}
-- plum on label
local plum = c:ellipse(31.5, 41.5, 3, 3)
c:part(plum, GV.ramp("#7b66b4", { shade = "#3e2f66" }), { flat = true })
c:px(30, 40, "#a894dc")
c:paint({ "..ll", ".l..", "w..." }, 31, 36, { l = "#7ab55c", w = "#5e2f1e" })
c:px(32, 38, "#5e2f1e")
-- glass shine
for y = 30, 46 do c:px(17, y, "#c8ecdc") end
-- lid ridge and seam
for x = 16, 47 do c:px(x, 21, "#b8661a") end
c:seam({ { 16, 18 }, { 47, 18 } })
c:button(19, 14)
local t = c:save(D .. "img-redraw-full/aseprite/ph/plum-jam.aseprite", D .. "img-redraw-full/png/ph/plum-jam.png")
print(GV.report(t))
