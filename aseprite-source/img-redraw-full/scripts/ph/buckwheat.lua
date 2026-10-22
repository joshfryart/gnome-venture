local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- tilted oval as polygon
local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg); local pts = {}
  for i = 0, 23 do
    local t = i / 24 * 2 * math.pi
    local x, y = rx * math.cos(t), ry * math.sin(t)
    pts[#pts + 1] = { cx + x * math.cos(a) - y * math.sin(a), cy + x * math.sin(a) + y * math.cos(a) }
  end
  return c:poly(pts)
end
local leaf = c:poly({ {32,51},{29,48},{26,45},{24,42},{24,39},{27,40},{30,42},{32,45},{33,49} })
local parts = {
  { "stem", c:line({ {32,55},{32,22} }, 3), GV.ramp("#2f5a2a"), { flat = true } },
  { "leaf", leaf, GV.ramp("#58a03e") },
}
local tan = GV.ramp("#dcb06a")
for i, y in ipairs({ 36, 29.5, 23 }) do
  parts[#parts + 1] = { "l" .. i, oval(26, y, 4.5, 6.5, -25), "gold" }
  parts[#parts + 1] = { "r" .. i, oval(38.5, y, 4.5, 6.5, 25), tan }
end
parts[#parts + 1] = { "top", oval(32, 15, 4.5, 7, 0), "gold" }
c:build(parts)
local t = c:save(O .. "aseprite/ph/buckwheat.aseprite", O .. "png/ph/buckwheat.png")
print(GV.report(t))
