local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cordR = GV.ramp("#f1ecd9")
local cords = c:rect(19, 12, 20, 30):add(c:rect(31, 12, 32, 36)):add(c:rect(43, 12, 44, 27))
local function hex(cx, cy, rw, h)
  -- pointed-top shield scute
  return c:poly({ {cx, cy}, {cx + rw, cy + 4}, {cx + rw - 2, cy + h}, {cx - rw + 2, cy + h}, {cx - rw, cy + 4} })
end
local left = hex(20, 28, 7, 13)
local centre = hex(32, 34, 8, 16)
local right = hex(44, 25, 7, 13)
local bar = c:rrect(12, 6, 52, 12, 3)
local p = c:build{
  { "cords", cords, cordR, { flat = true } },
  { "left", left, GV.ramp("#b99346") },
  { "right", right, GV.ramp("#b99346") },
  { "centre", centre, GV.ramp("#8c6a28") },
  { "bar", bar, "wood" },
}
-- knots on the bar
for _, x in ipairs({ 19, 31, 43 }) do
  c:fill(c:rect(x, 12, x + 2, 14), "#f1ecd9"); c:px(x + 2, 14, cordR.shade)
end
-- scute ridges + plate lines
local function ridge(cx, cy, h, r)
  for y = cy + 3, cy + h - 2 do c:px(cx, y, r.shade) end
  for dx = -3, 3 do c:px(cx + dx, cy + math.floor(h * 0.55), r.shade) end
end
ridge(20, 28, 13, p.left.r); ridge(44, 25, 13, p.right.r); ridge(32, 34, 16, p.centre.r)
-- wood grain on bar
c:paint({ "ss..sss" }, 22, 9, { s = GV.R.wood.shade })
c:paint({ "sss..ss" }, 36, 10, { s = GV.R.wood.shade })
local t = c:save(O .. "aseprite/animals/item-scute-wind-chime.aseprite", O .. "png/animals/item-scute-wind-chime.png")
print(GV.report(t))
