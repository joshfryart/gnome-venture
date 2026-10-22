local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local function bar(x0, y0, x1, y1, w0, w1)
  local dx, dy = x1 - x0, y1 - y0
  local l = math.sqrt(dx*dx + dy*dy)
  local nx, ny = -dy / l, dx / l
  return c:poly({ {x0 + nx*w0, y0 + ny*w0}, {x1 + nx*w1, y1 + ny*w1}, {x1 - nx*w1, y1 - ny*w1}, {x0 - nx*w0, y0 - ny*w0} })
end
local upper = bar(12, 41, 39, 20, 3, 2.5)
local lower = bar(19, 49, 45, 27, 3, 2.5)
local centre = bar(14, 47, 42, 24, 4.5, 3.5)
centre:add(c:ellipse(15, 46, 4.5, 4.5))
local blades = c:poly({ {36,25}, {42,14}, {47,7}, {46,16}, {42,26} })
blades:add(c:poly({ {40,28}, {47,17}, {54,11}, {51,20}, {45,29} }))
blades:add(c:poly({ {43,31}, {49,26}, {55,24}, {51,30}, {45,34} }))
local band = bar(19, 33, 30, 49, 1.6, 1.6)
c:build{
  { "blades", blades, "moss" },
  { "upper", upper, GV.ramp("#e2c048") },
  { "lower", lower, GV.ramp("#e2c048") },
  { "centre", centre, GV.ramp("#f5d870"), { gloss = { 18, 40 } } },
  { "band", band, "wood", { flat = true } },
}

c:button(17, 30)
local t = c:save(O .. "aseprite/ph/lemongrass.aseprite", O .. "png/ph/lemongrass.png")
print(GV.report(t))
