local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- wide-based trapezoid sand tray
local tray = c:poly({ { 12, 53 }, { 18, 38 }, { 46, 38 }, { 52, 53 } })
-- big smooth sphere perched on top, sitting slightly into the tray
local boulder = c:ellipse(31.5, 26, 13, 13)

local p = c:build{
  { "tray",    tray, GV.ramp("#968f96") },
  { "boulder", boulder, GV.ramp("#d6c9b6") },
}
-- raked gravel lines: gentle arcs on the tray, only on visible tray pixels
local rake = "#c9c5bc"
local function rakeRow(y, x0, x1)
  for x = x0, x1 do
    if p.tray.m:has(x, y) and not boulder:has(x, y) then c:px(x, y, rake) end
  end
end
rakeRow(43, 18, 45)
rakeRow(47, 16, 47)
rakeRow(51, 15, 49)
c:ground(32, 55, 19, 2.5)
local t = c:save(O .. "aseprite/ph/rock-garden.aseprite", O .. "png/ph/rock-garden.png")
print(GV.report(t))
