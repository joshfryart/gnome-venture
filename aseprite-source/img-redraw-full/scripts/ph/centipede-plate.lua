local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- legs behind plate, bent outward
for _, y in ipairs({20, 31, 42}) do
  c:limb({ {15, y}, {10, y + 1}, {8, y + 5} }, 2)
  c:limb({ {49, y}, {54, y + 1}, {56, y + 5} }, 2)
end
local plate = c:poly({ {32, 7}, {53, 18}, {53, 47}, {32, 58}, {11, 47}, {11, 18} })
local inner = c:poly({ {32, 14}, {47, 22}, {47, 43}, {32, 51}, {17, 43}, {17, 22} })
local p = c:build{
  { "plate", plate, "moss" },
  { "inner", inner, "#4a8a3e", { light = plate } },
}
-- segment bars clipped to inner plate
for _, y in ipairs({21, 29, 37, 44}) do
  local bar = c:rect(16, y, 48, y + 1):clip(inner:shrink(1))
  c:fill(bar, "#2f5a2a")
  c:fill(c:rect(16, y + 2, 48, y + 2):clip(inner:shrink(1)), "#6a9a3a")
end
-- spine ridge
c:fill(c:rect(31, 11, 32, 54), "#c8d77a")
c:fill(c:rect(33, 11, 33, 54), "#4a8a3e")
-- head notch
c:fill(c:rect(29, 9, 34, 11):clip(plate), "#3e2f66")
local t = c:save(O .. "aseprite/ph/centipede-plate.aseprite", O .. "png/ph/centipede-plate.png")
print(GV.report(t))
