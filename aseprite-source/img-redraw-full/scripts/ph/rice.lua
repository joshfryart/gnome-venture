local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- tilted ellipse (deg > 0 leans the top to the right)
local function tel(cx, cy, rx, ry, deg)
  local m, a = c:mask(), math.rad(deg)
  local ca, sa = math.cos(a), math.sin(a)
  for y = math.floor(cy - ry - rx), math.ceil(cy + ry + rx) do
    for x = math.floor(cx - ry - rx), math.ceil(cx + ry + rx) do
      local px, py = x - cx, y - cy
      local u = px * ca + py * sa
      local v = -px * sa + py * ca
      if (u / rx) ^ 2 + (v / ry) ^ 2 <= 1 then m:set(x, y) end
    end
  end
  return m
end
local cream = GV.ramp("#f1ece0")
local tan = GV.ramp("#dcb06a")
local leaf = c:line({ {31, 53}, {28, 50}, {25, 47} }, 3):add(c:line({ {25, 47}, {22, 44}, {20, 40} }, 2))
leaf:add(c:poly({ {32, 56}, {27, 50}, {24, 46}, {29, 49}, {33, 53} }))
local parts = {
  { "stem", c:rrect(31, 24, 33, 55, 1), "#2e5a2c", { flat = true } },
  { "leaf", leaf, GV.ramp("#58a03e"), { gloss = false } },
}
local ys = { 40, 32, 24 }
for i, y in ipairs(ys) do
  parts[#parts + 1] = { "l" .. i, tel(26, y, 4, 6.5, -28), cream }
  parts[#parts + 1] = { "r" .. i, tel(38, y + 1, 4, 6.5, 28), tan }
end
parts[#parts + 1] = { "top", tel(32, 16, 4.5, 7, 0), cream }
c:build(parts)
c:ground(32, 57, 8, 1.5)
local t = c:save(O .. "aseprite/ph/rice.aseprite", O .. "png/ph/rice.png")
print(GV.report(t))
