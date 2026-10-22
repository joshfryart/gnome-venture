local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local wood  = GV.ramp("#a5663a")
local stone = GV.ramp("#968f96")
local lip   = GV.ramp("#6a6070")
local door  = GV.ramp("#8c4a1a")

local p = c:build{
  { "walls", c:rect(11, 29, 52, 50), wood },
  { "roof",  c:poly({ {7, 29}, {16, 14}, {48, 14}, {57, 29} }), stone },
  { "lip",   c:rect(6, 28, 57, 31), lip, { gloss = false } },
  { "door",  c:rect(23, 34, 40, 50), door, { gloss = false } },
}
-- plank lines on walls (outside the door)
for _, y in ipairs({ 37, 44 }) do
  for x = 12, 51 do
    if not p.door.m:has(x, y) then c:px(x, y, wood.deep) end
  end
end
-- door: frame, X brace and centre line
local dk = "#44281c"
c:fill(c:line({ {25, 36}, {38, 48} }, 2), dk)
c:fill(c:line({ {38, 36}, {25, 48} }, 2), dk)
for y = 35, 49 do c:px(31, y, dk); c:px(32, y, dk) end
for x = 24, 39 do c:px(x, 35, dk) end
-- tools hanging at the sides
c:part(c:line({ {46, 48}, {47, 36} }, 2), "#5e2f1e", { flat = true })
c:part(c:poly({ {43, 34}, {51, 34}, {50, 39}, {45, 39} }), stone, { flat = true })
c:part(c:line({ {16, 48}, {15, 37} }, 2), "#5e2f1e", { flat = true })
c:part(c:rrect(13, 34, 19, 37, 1), stone, { flat = true })
-- corner lamps
c:part(c:rrect(6, 32, 10, 38, 2), "gold", { gloss = { 7, 33 } })
c:part(c:rrect(53, 32, 57, 38, 2), "gold", { gloss = { 54, 33 } })
c:seam({ {12, 29}, {52, 29} })
c:ground(31.5, 52, 22, 1.5)
local t = c:save(O .. "aseprite/ph/tool_shed-lantern.aseprite", O .. "png/ph/tool_shed-lantern.png")
print(GV.report(t))
