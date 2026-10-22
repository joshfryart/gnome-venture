local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local vane = c:poly({ {16, 54}, {17, 41}, {21, 26}, {31, 16}, {43, 10}, {51, 8}, {49, 16}, {45, 26},
  {41, 30}, {38, 29}, {40, 34}, {37, 39}, {27, 48}, {17, 55} })
local tip = vane:copy():clip(c:poly({ {23, 9}, {57, 34}, {64, 34}, {64, 0}, {23, 0} }))
vane:cut(tip)
local quill = c:line({ {13, 57}, {16, 53} }, 3)
c:build{
  { "vane", vane, GV.ramp("#c9c5bc"), { light = vane:copy():add(tip) } },
  { "tip",  tip,  GV.ramp("#5b6470"), { gloss = false } },
  { "quill", quill, GV.ramp("#ecc58a"), { flat = true } },
}
c:fill(c:line({ {16, 53}, {44, 17} }, 2), "#8b8f96")
local barb = "#8b8f96"
for _, b in ipairs({ { {25, 41}, {20, 37} }, { {30, 34}, {24, 29} }, { {35, 28}, {30, 22} },
                     { {27, 39}, {31, 41} }, { {33, 31}, {36, 33} } }) do
  c:fill(c:line(b, 1):clip(vane), barb)
end
local t = c:save(O .. "aseprite/ph/gull-feather.aseprite", O .. "png/ph/gull-feather.png")
print(GV.report(t))
