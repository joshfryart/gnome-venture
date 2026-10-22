local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local steel = GV.ramp("#c9c5bc")
local head = c:ellipse(31.5, 34, 22, 23):cut(c:ellipse(31.5, 39, 19.5, 19)):cut(c:rect(0, 38, 63, 63))
local tips = head:copy():clip(c:rect(0, 31, 63, 63))
local p = c:build{
  { "handle", c:rrect(29, 14, 34, 55, 3), "wood" },
  { "head", head, steel, { light = head } },
  { "tips", tips, GV.ramp("#8b8f96"), { flat = true } },
  { "collar", c:rrect(26, 9, 37, 18, 3), GV.ramp("#5b6470") },
}
c:seam({ {26, 14}, {37, 14} })
c:seam({ {31, 26}, {31, 53} })
local t = c:save(O .. "aseprite/gather/pick-pick.aseprite", O .. "png/gather/pick-pick.png")
print(GV.report(t))
