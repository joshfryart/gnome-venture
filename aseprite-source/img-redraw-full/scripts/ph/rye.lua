local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local function oval(cx, cy, rx, ry, deg)
  local m, a = c:mask(), math.rad(deg)
  local ca, sa = math.cos(a), math.sin(a)
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x - cx, y - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / rx) ^ 2 + (v / ry) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local sand, brown = GV.ramp("#dcb06a"), GV.ramp("#a5663a")
local parts = {
  { "stem", c:rect(31, 22, 33, 56), GV.ramp("#2e5a2c"), { flat = true } },
  { "leaf", c:poly({ {33, 55}, {28, 51}, {23, 46}, {19, 40}, {23, 42}, {28, 46}, {34, 50} }), GV.ramp("#58a03e"), { gloss = false } },
}
for i, y in ipairs({ 40, 33, 26 }) do
  parts[#parts + 1] = { "l" .. i, oval(26.5, y, 4.5, 7, 25), sand, { gloss = (i == 3) and { 24, 21 } or false } }
  parts[#parts + 1] = { "r" .. i, oval(37.5, y, 4.5, 7, -25), brown, { gloss = false } }
end
parts[#parts + 1] = { "top", oval(32, 18, 4.5, 8, 0), sand, { gloss = { 30, 13 } } }
c:build(parts)
-- awn bristles fanning up from the top kernel (outside the halo silhouette)
local awn = c:line({ {30, 10}, {27, 4} }, 1)
awn:add(c:line({ {32, 9}, {32, 3} }, 1)):add(c:line({ {34, 10}, {37, 4} }, 1))
awn:add(c:line({ {29, 12}, {25, 7} }, 1)):add(c:line({ {35, 12}, {39, 7} }, 1))
c:part(awn, GV.ramp("#7a3a14", { base = "#7a3a14", rim = "#7a3a14" }), { flat = true, solid = false, contour = false, contact = false })
local t = c:save(O .. "aseprite/ph/rye.aseprite", O .. "png/ph/rye.png")
print(GV.report(t))
