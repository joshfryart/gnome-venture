local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- S-wave spine: tail low-left, crest, trough, rising to head upper-right
local spine = { {12,43}, {15,35}, {19,29}, {24,27}, {28,30}, {32,35}, {36,37}, {40,34}, {44,29}, {48,25} }
local body = c:mask()
local function pt(i, t)
  local a, b = spine[i], spine[i + 1]
  return a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t
end
for i = 1, #spine - 1 do
  for s = 0, 8 do
    local x, y = pt(i, s / 8)
    body:add(c:ellipse(x, y, 4.6, 4.6))
  end
end

-- bands across the body (perpendicular strokes clipped to the body)
local function band(x0, y0, x1, y1)
  return c:line({ {x0, y0}, {x1, y1} }, 3):clip(body)
end
local r1 = band(14, 31, 23, 36)
local r2 = band(25, 37, 31, 25)
local r3 = band(37, 43, 41, 29)
local clit = band(30, 41, 35, 29)

local head = c:ellipse(49, 24, 8, 8)
local pink = GV.ramp("#e8a0a8")
local ring = GV.ramp("#d9667f")
c:build{
  { "body", body, pink, { light = body:copy():add(head) } },
  { "r1", r1, ring, { flat = true, contour = false, contact = false } },
  { "r2", r2, ring, { flat = true, contour = false, contact = false } },
  { "r3", r3, ring, { flat = true, contour = false, contact = false } },
  { "head", head, pink },
}
c:eye(45, 21, true); c:eye(51, 21, true)
c:paint({ "u...u", ".uuu." }, 47, 26, { u = "#2a1a10" })
local t = c:save(O .. "aseprite/ico/ico-worm.aseprite", O .. "png/ico/ico-worm.png")
print(GV.report(t))
