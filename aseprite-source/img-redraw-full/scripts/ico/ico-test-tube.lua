local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- tube axis from bottom (23,47) to top (42,15); thick line gives a round-ended capsule
local tube = c:line({ {24, 46}, {41, 17} }, 11):add(c:ellipse(24, 46, 5.5, 5.5))
-- liquid: lower part of tube, cut by a line perpendicular to axis through (32,32)
-- axis dir ~ (0.51,-0.86); keep points with (x-32)*0.51 - (y-32)*0.86 < 0
local liq = c:mask()
tube:each(function(x, y)
  if (x - 32) * 0.51 - (y - 32) * 0.86 < -1 then liq:set(x, y) end
end)
liq = liq:shrink(1)
local cap = c:poly({ {36, 7}, {50, 15}, {46, 22}, {32, 14} })

local p = c:build{
  { "tube",   tube, "#cfe6ee", { pale = true } },
  { "liquid", liq, "#3fbf72", { light = tube, rim = false } },
  { "cap",    cap, "stone" },
}
-- meniscus: lighter 1px line along the liquid top edge
liq:each(function(x, y)
  if not liq:has(x + 1, y - 1) and not liq:has(x, y - 1) then c:px(x, y, "#9fe6b0") end
end)
c:part(c:ellipse(28, 40, 2, 2), "#c8f2d6", { flat = true })
c:px(32, 36, "#c8f2d6"); c:px(33, 36, "#c8f2d6")
local t = c:save(O .. "aseprite/ico/ico-test-tube.aseprite", O .. "png/ico/ico-test-tube.png")
print(GV.report(t))
