local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local function rell(cx, cy, rx, ry, deg)
  local a = math.rad(deg); local pts = {}
  for i = 0, 35 do
    local t = i / 36 * 2 * math.pi
    local dx, dy = rx * math.cos(t), ry * math.sin(t)
    pts[#pts + 1] = { cx + dx * math.cos(a) - dy * math.sin(a) + 0.5, cy + dx * math.sin(a) + dy * math.cos(a) + 0.5 }
  end
  return c:poly(pts)
end

local cream = GV.ramp("#f1ece0")
local tan = GV.ramp("#dcb06a")
local parts = {
  { "stalk", c:rect(31, 22, 33, 57), GV.ramp("#4a8a3e", { deep = "#2f5a2a" }) },
  { "leaf", c:line({ {32, 54}, {28, 51}, {24, 49}, {20, 47}, {17, 44} }, 3):add(c:line({ {31, 55}, {26, 52} }, 4)), GV.ramp("#58a03e") },
}
local ys = { 21, 29, 37 }
for i, y in ipairs(ys) do
  parts[#parts + 1] = { "L" .. i, rell(25, y, 3.6, 6.2, -25), cream }
  parts[#parts + 1] = { "R" .. i, rell(39, y, 3.6, 6.2, 25), tan }
end
parts[#parts + 1] = { "top", c:ellipse(32, 12, 4, 7.5), cream }
c:build(parts)

-- awn tips
for _, y in ipairs(ys) do
  c:px(21, y - 7, GV.C.umber); c:px(42, y - 7, GV.C.umber)
end
c:px(32, 3, GV.C.umber)

local t = c:save(O .. "aseprite/ph/wild-rice.aseprite", O .. "png/ph/wild-rice.png")
print(GV.report(t))
