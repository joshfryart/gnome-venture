local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local x0, x1, yEnd, sag = 11, 52, 17, 6
local function cy(x)
  local u = (x - 31.5) / ((x1 - x0) / 2)
  return math.floor(yEnd + sag * (1 - u * u) + 0.5)
end
-- cord
local pts = {}
for x = x0, x1, 3 do pts[#pts + 1] = { x, cy(x) } end
pts[#pts + 1] = { x1, cy(x1) }
local parts = { { "cord", c:line(pts, 2), "wood", { flat = true } } }
-- seven pennants
local cols = { "#d6322b", "#e8a317", "#58a03e", "#3f93b2", "#7a5cc0", "#e46a9b", "#e0501f" }
local w = 6
for i = 1, 7 do
  local a = x0 + (i - 1) * w
  local b = a + w
  local mid = (a + b) / 2
  local tip = cy(mid) + 13 - math.floor(math.abs(i - 4) * 0.5)
  local m = c:poly({ { a, cy(a) + 1 }, { b, cy(b) + 1 }, { b, cy(b) + 3 }, { mid + 0.5, tip }, { mid - 0.5, tip }, { a, cy(a) + 3 } })
  parts[#parts + 1] = { "p" .. i, m, GV.ramp(cols[i]), { gloss = false, contact = false } }
end
-- gold bobbles at cord ends
parts[#parts + 1] = { "bl", c:ellipse(x0, yEnd, 2.5, 2.5), "gold", { gloss = false } }
parts[#parts + 1] = { "br", c:ellipse(x1, yEnd, 2.5, 2.5), "gold", { gloss = false } }
-- baubles below
parts[#parts + 1] = { "b1", c:ellipse(25, 45, 3.5, 3.5), GV.ramp("#e0501f"), { gloss = false } }
parts[#parts + 1] = { "b2", c:ellipse(39, 43, 3.5, 3.5), GV.ramp("#e46a9b"), { gloss = false } }
c:build(parts)
-- hem stitches along each pennant top
for i = 1, 7 do
  local a = x0 + (i - 1) * w
  c:px(a + 2, cy(a + 2) + 3, GV.C.gold)
  c:px(a + 4, cy(a + 4) + 3, GV.C.gold)
end
-- glints
c:px(x0 - 1, yEnd - 1, GV.R.gold.gloss); c:px(x1 - 1, yEnd - 1, GV.R.gold.gloss)
c:px(24, 43, GV.ramp("#e0501f").gloss); c:px(23, 44, GV.ramp("#e0501f").gloss)
c:px(38, 41, GV.ramp("#e46a9b").gloss); c:px(37, 42, GV.ramp("#e46a9b").gloss)
local t = c:save(O .. "aseprite/ph/nav-festival.aseprite", O .. "png/ph/nav-festival.png")
print(GV.report(t))
