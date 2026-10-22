local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local bright = "red"
local deepR = GV.ramp("#ae2a2a")
local B = {
  { "b1", 18.5, 48, deepR }, { "b2", 32.5, 49, bright }, { "b3", 46.5, 48, deepR },
  { "m1", 25.5, 38, bright }, { "m2", 39.5, 38, deepR },
  { "t1", 32.5, 28, bright },
}
local parts = {}
parts[1] = { "stem", c:rrect(31, 13, 33, 22, 1), "#2f5a2a", { flat = true } }
for _, b in ipairs(B) do
  parts[#parts + 1] = { b[1], c:ellipse(b[2], b[3], 7.5, 7.5), b[4], { gloss = { math.floor(b[2]) - 4, b[3] - 4 } } }
end
parts[#parts + 1] = { "leaf", c:poly({ {33, 18}, {37, 11}, {45, 7}, {47, 9}, {44, 16}, {36, 21} }), "#4a8a3e", { cres = 2, deep = 1 } }
local p = c:build(parts)
c:fill(c:line({ {35, 17}, {44, 10} }, 1), "#7ab55c")
-- crown dimples
for _, b in ipairs(B) do
  local x = math.floor(b[2]) + 2
  c:paint({ "dd", "dd" }, x, b[3] + 2, { d = "#6b1b2c" })
end
local t = c:save(O .. "aseprite/ph/lingonberry.aseprite", O .. "png/ph/lingonberry.png")
print(GV.report(t))
