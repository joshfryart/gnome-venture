local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local copper = GV.ramp("#8c4a1a")
local light = GV.ramp("#c4925f")
local rose = GV.ramp("#a9d6ea")
-- handle arch (ring segment above the body)
local handle = c:ellipse(22.5, 30, 13, 13):cut(c:ellipse(22.5, 30, 9, 9)):cut(c:rect(0, 30, 63, 63))
-- spout: diagonal shaft, snapped near the tip; rose head separate
local spout = c:line({ {35, 40}, {44, 33} }, 5)
-- body: tapered pail
local body = c:poly({ {8, 29}, {38, 29}, {35, 54}, {11, 54} })
body:add(c:rect(7, 28, 39, 31))          -- rolled rim
body:cut(c:poly({ {6, 40}, {11, 43}, {6, 46} }))   -- chipped left side
local p = c:build{
  { "handle", handle, light },
  { "spout", spout, light },
  { "body", body, copper },
}
-- snapped spout end + rose head, hanging off the break
local tip = c:line({ {47, 30}, {49, 29} }, 5)
c:part(tip, light, { flat = true })
c:part(c:ellipse(52.5, 25.5, 3.5, 3.5), rose, { gloss = false })
c:px(51, 24, "#2a3c6c"); c:px(53, 25, "#2a3c6c"); c:px(52, 27, "#2a3c6c")
-- loose fragment on the ground
c:part(c:poly({ {41, 50}, {46, 49}, {47, 53}, {42, 54} }), copper, { flat = true })
-- rim band line
c:fill(c:line({ {9, 32}, {37, 32} }, 1), "#5e2f1e")
-- crack zigzag through handle and body
c:fill(c:line({ {25, 17}, {27, 21} }, 2), "#2a1a10")
c:fill(c:line({ {24, 30}, {28, 36}, {23, 42}, {27, 48}, {25, 53} }, 2), "#2a1a10")
local t = c:save(O .. "aseprite/ph/broken-copper-watering-can.aseprite", O .. "png/ph/broken-copper-watering-can.png")
print(GV.report(t))
