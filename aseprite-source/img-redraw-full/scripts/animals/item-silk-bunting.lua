local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(B .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- sagging cord: quadratic from (12,17) through a low point (31.5,26) to (51,17)
local pts = {}
for i = 0, 12 do
  local t = i / 12
  local x = 12 + 39 * t
  local y = 17 + 4 * 9 * t * (1 - t)
  pts[#pts + 1] = { math.floor(x + 0.5), math.floor(y + 0.5) }
end
local cord = c:line(pts, 2)
local pink = c:poly({ {13, 19}, {26, 23}, {18, 37} })
local blue = c:poly({ {25, 25}, {39, 25}, {32, 42} })
local gold = c:poly({ {38, 23}, {51, 19}, {46, 37} })
local p = c:build{
  { "cord", cord, "#6b5a3a", { flat = true } },
  { "pink", pink, "#e9a0b8" },
  { "blue", blue, "#8fc7d9" },
  { "gold", gold, "#f2d27a" },
}
c:seam({ {15, 21}, {24, 24} })
c:seam({ {27, 27}, {37, 27} })
c:seam({ {40, 25}, {49, 22} })
c:button(10, 15); c:button(50, 15)
local t = c:save(B .. "img-redraw-full/aseprite/animals/item-silk-bunting.aseprite", B .. "img-redraw-full/png/animals/item-silk-bunting.png")
print(GV.report(t))
