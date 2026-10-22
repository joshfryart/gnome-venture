local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local O = D .. "img-redraw-full/"

local trunk = c:rrect(28, 36, 35, 55, 2)
trunk:add(c:poly({ {25, 56}, {38, 56}, {35, 51}, {28, 51} }))
-- wide dome crown, flattened bottom with drooping fringe strands
local crown = c:ellipse(31.5, 25, 22, 17):cut(c:rect(0, 38, 63, 63))
crown:add(c:rrect(12, 30, 51, 39, 4))
for _, x in ipairs({ 13, 19, 25, 37, 43, 49 }) do
  local len = (x == 13 or x == 49) and 4 or 7
  crown:add(c:rrect(x, 36, x + 2, 38 + len, 1))
end
local lobeL = c:ellipse(21, 28, 8, 7):clip(crown)
local lobeR = c:ellipse(43, 21, 7, 6):clip(crown)

local p = c:build{
  { "trunk", trunk, GV.ramp("#b6814d", { rim = "#f0d49a" }) },
  { "crown", crown, GV.ramp("#58a03e"), { gloss = false } },
  { "lobeR", lobeR, GV.ramp("#2e5a2c"), { gloss = false, light = crown } },
  { "lobeL", lobeL, GV.ramp("#7ab55c"), { gloss = false, contact = false } },
}
-- leaf-strand lines falling through the crown
for _, x in ipairs({ 28, 34 }) do
  for y = 14, 30, 4 do c:px(x, y, "#4a8a3e"); c:px(x, y + 1, "#4a8a3e") end
end
c:gloss(crown, GV.ramp("#58a03e"), { 22, 14 })
c:ground(31.5, 57, 15, 2)
local t = c:save(O .. "aseprite/ph/weeping-willow.aseprite", O .. "png/ph/weeping-willow.png")
print(GV.report(t))
