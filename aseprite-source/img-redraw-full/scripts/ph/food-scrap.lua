local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- U-shaped leaf cup: lower half ellipse plus flared rim tips
local cup = c:ellipse(31.5, 30, 21, 24):cut(c:rect(0, 0, 63, 29))
cup:add(c:poly({ { 9, 22 }, { 18, 28 }, { 14, 32 }, { 10, 30 } }))
cup:add(c:poly({ { 55, 22 }, { 46, 28 }, { 50, 32 }, { 54, 30 } }))
cup:cut(c:rect(0, 55, 63, 63))
local crust = c:rrect(18, 20, 45, 29, 4)
local red = c:ellipse(25, 39, 4.5, 4.5)
local gold = c:ellipse(38, 43, 4.5, 4.5)

local p = c:build{
  { "cup", cup, GV.ramp("#6a9a3a") },
  { "crust", crust, GV.ramp("#d9a660"), { stitch = false } },
  { "red", red, GV.ramp("#d6322b") },
  { "gold", gold, "gold" },
}
-- leaf vein from the base up to the rim
c:seam({ { 31, 52 }, { 31, 47 } }, { on = 1, off = 0, gap = "#5e2f1e" })
c:paint({ "vv", "vv" }, 30, 49, { v = "#44281c" })
c:paint({ "vv", "vv" }, 31, 51, { v = "#44281c" })
-- crust crumb pores
c:px(24, 25, "#8a4f2a"); c:px(30, 24, "#8a4f2a"); c:px(37, 25, "#8a4f2a"); c:px(42, 23, "#8a4f2a")
local t = c:save(O .. "aseprite/ph/food-scrap.aseprite", O .. "png/ph/food-scrap.png")
print(GV.report(t))
