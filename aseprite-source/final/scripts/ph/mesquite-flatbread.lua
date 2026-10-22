local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local disc = c:ellipse(31.5, 34, 23, 15)
local flap = c:ellipse(31.5, 34, 23, 15):clip(c:ellipse(52, 34, 15, 17)):add(c:ellipse(45, 34, 6, 13):clip(c:ellipse(31.5,34,23,15)))
local p = c:build{
  { "disc", disc, GV.ramp("#c9a96e") },
  { "flap", flap, GV.ramp("#d9a660"), { gloss = {44, 24} } },
}
-- lower rim band on the disc (left/bottom edge, thick crust)
local band = disc:copy():cut(c:ellipse(31.5, 32.5, 22, 13.5)):cut(flap)
c:fill(band:clip(c:rect(0, 34, 63, 63)), "#b07a45")
-- char blisters (beans)
local beans = { {16, 30}, {24, 39}, {29, 25}, {19, 43}, {33, 33} }
for _, b in ipairs(beans) do
  c:paint({ ".ss", "sss", "ss." }, b[1], b[2], { s = "#7a4a1f" })
end
c:paint({ ".s", "ss" }, 48, 38, { s = "#8a4f2a" })
c:paint({ "s." , "ss" }, 45, 29, { s = "#8a4f2a" })
-- flour dusting
for _, d in ipairs({ {14, 26}, {20, 24}, {23, 33}, {12, 34}, {27, 30} }) do c:px(d[1], d[2], "#f1ece0") end
local t = c:save(O .. "aseprite/ph/mesquite-flatbread.aseprite", O .. "png/ph/mesquite-flatbread.png")
print(GV.report(t))
