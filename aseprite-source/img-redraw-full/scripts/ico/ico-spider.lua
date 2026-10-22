local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- eight bent legs, elbows up, fanning outward
for i = 0, 3 do
  local y0 = 23 + i * 7
  c:limb({ {28, y0}, {20, y0 - 6}, {14, y0 + 1 + i} }, 3)
  c:limb({ {35, y0}, {43, y0 - 6}, {49, y0 + 1 + i} }, 3)
end

local abd  = c:ellipse(31.5, 40, 10, 11)
local head = c:ellipse(31.5, 22, 7, 7)
c:build{
  { "abdomen", abd,  GV.ramp("#f08a24") },
  { "head",    head, GV.ramp("#e0501f") },
}
local dia = { ".x.", "xxx", ".x." }
c:spot(c:ascii(dia, 26, 38), "#e8a317", "#f5cf6a")
c:spot(c:ascii(dia, 35, 38), "#e8a317", "#f5cf6a")
c:spot(c:ascii(dia, 30, 44), "#e8a317", "#f5cf6a")
c:eye(27, 20, true); c:eye(33, 20, true)

local t = c:save(O .. "aseprite/ico/ico-spider.aseprite", O .. "png/ico/ico-spider.png")
print(GV.report(t))
