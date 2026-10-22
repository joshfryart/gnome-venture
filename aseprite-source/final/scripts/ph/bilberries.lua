local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local A = "water"
local B = GV.ramp("#2f5a9a")
local berries = {
  { 19, 44, A }, { 32, 44, B }, { 45, 44, A },
  { 25.5, 34, B }, { 38.5, 34, A },
  { 32, 24, A },
}
local parts = {}
for i, b in ipairs(berries) do
  parts[#parts + 1] = { "b" .. i, c:ellipse(b[1], b[2], 7, 7), b[3] }
end
parts[#parts + 1] = { "stalk", c:rect(31, 13, 33, 18), "leaf", { flat = true } }
parts[#parts + 1] = { "leaf", c:poly({ {33, 13}, {38, 8}, {45, 8}, {44, 11}, {38, 15} }), "moss", { gloss = false } }
c:build(parts)
for _, b in ipairs(berries) do
  local x, y = math.floor(b[1] + 3), b[2] - 4
  c:paint({ ".d.", "ddd", ".d." }, x, y, { d = "#2a3c6c" })
end
c:ground(32, 52, 18, 1.5)
local t = c:save(O .. "aseprite/ph/bilberries.aseprite", O .. "png/ph/bilberries.png")
print(GV.report(t))
