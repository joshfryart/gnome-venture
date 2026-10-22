local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dish = c:ellipse(31.5, 41, 26, 13)
local crust = c:ellipse(31.5, 36, 26, 12)
local fill = c:ellipse(31.5, 36, 18, 8)
local lat = c:line({ {18, 31}, {45, 41} }, 3):add(c:line({ {45, 31}, {18, 41} }, 3)):clip(fill:shrink(1))
local p = c:build{
  { "dish", dish, GV.ramp("#a5663a") },
  { "crust", crust, GV.ramp("#dcb06a"), { gloss = { 12, 31 } } },
  { "fill", fill, "red", { gloss = { 20, 33 } } },
  { "lat", lat, GV.ramp("#dcb06a"), { flat = true } },
}
local dots = { {11, 35}, {20, 27}, {41, 26}, {52, 35}, {44, 45}, {17, 44}, {30, 25}, {30, 46} }
for _, d in ipairs(dots) do
  c:paint({ "ab", "bb" }, d[1], d[2], { a = "#e8cf98", b = "#c9a96e" })
end
c:seam({ {6, 42}, {10, 46}, {18, 50}, {31, 52}, {45, 50}, {53, 46}, {57, 42} })
local t = c:save(O .. "aseprite/ph/apple-crumble.aseprite", O .. "png/ph/apple-crumble.png")
print(GV.report(t))
