local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local twig = c:line({ { 47, 17 }, { 33, 30 } }, 3)
-- lobed oak leaf: chain of circles along an axis
local function leaf(x0, y0, x1, y1, r)
  local m = c:mask()
  for i = 0, 3 do
    local t = i / 3
    local x, y = x0 + (x1 - x0) * t, y0 + (y1 - y0) * t
    local rr = (i == 0 or i == 3) and r - 1 or r
    if i == 3 then rr = r - 1.5 end
    m:add(c:ellipse(x, y, rr, rr))
  end
  return m
end
local leafA = leaf(43, 19, 35, 14.5, 3.5)
local leafB = leaf(46, 22, 49.5, 31, 3.5)
local gall = c:ellipse(24.5, 41, 13, 13)
gall:add(c:ellipse(14, 33, 2.5, 2.5)):add(c:ellipse(37, 47, 2.5, 2.5)):add(c:ellipse(19, 52, 2.5, 2.5))
local scar = c:ellipse(32, 30, 3, 2)

local p = c:build{
  { "leafB", leafB, "moss" },
  { "twig", twig, GV.ramp("#5e2f1e"), { flat = true } },
  { "leafA", leafA, "moss" },
  { "gall", gall, "wood", { gloss = { 18, 35 } } },
  { "scar", scar, GV.ramp("#5e2f1e"), { flat = true } },
}
-- leaf veins
c:fill(c:line({ { 42, 18 }, { 36, 15 } }, 1), "#4a8a3e")
c:fill(c:line({ { 46, 23 }, { 49, 29 } }, 1), "#4a8a3e")
-- bumpy texture dots
for _, d in ipairs({ { 25, 35 }, { 32, 39 }, { 19, 44 }, { 27, 49 }, { 33, 33 } }) do
  c:fill(c:ellipse(d[1], d[2], 1, 1), "#8a4f2a")
end
c:fill(c:rect(30, 43, 32, 45), "#2a1a10")
c:px(30, 43, "#5e2f1e")

local t = c:save(O .. "aseprite/ph/oak-gall.aseprite", O .. "png/ph/oak-gall.png")
print(GV.report(t))
