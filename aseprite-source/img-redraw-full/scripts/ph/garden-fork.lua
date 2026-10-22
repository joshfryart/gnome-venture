-- ph/garden-fork : upright three-tine garden fork on a wood shaft
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local steel = GV.ramp("#8b8f96")
local wood = GV.ramp("#b6814d")

-- U-shaped tine head: outer tines curve in to meet the centre tine at the bottom
local tines = c:line({ {16,9}, {16,22}, {17,26}, {20,29}, {25,31}, {32,32}, {39,31}, {44,29}, {47,26}, {48,22}, {48,9} }, 4)
tines:add(c:line({ {32,9}, {32,32} }, 4))
-- rounded tips
for _, x in ipairs({ 16, 32, 48 }) do
  tines:add(c:ellipse(x + 0.5, 8.5, 2, 2))
end

local handle = c:rrect(29, 33, 35, 56, 3)

c:build{
  { "handle", handle, wood, { gloss = { 30, 40 } } },
  { "tines", tines, steel, { gloss = { 15, 11 } } },
  { "collar", c:rrect(27, 29, 37, 36, 2), "#5b6470", { gloss = false } },
}
-- wrap stitch around the collar
c:seam({ {28, 32}, {36, 32} })

c:ground(32, 57, 17, 1.5)
local t = c:save(O .. "aseprite/ph/garden-fork.aseprite", O .. "png/ph/garden-fork.png")
print(GV.report(t))
