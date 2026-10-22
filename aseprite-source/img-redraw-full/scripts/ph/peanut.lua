local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local function rotEllipse(cx, cy, rx, ry, a)
  local m = c:mask(); local ca, sa = math.cos(a), math.sin(a)
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x - cx, y - cy
    local u, v = dx*ca + dy*sa, -dx*sa + dy*ca
    if (u*u)/(rx*rx) + (v*v)/(ry*ry) <= 1 then m:set(x, y) end
  end end
  return m
end
local a = -0.68 -- tilt up to the right
local shell = rotEllipse(21, 42, 12, 12, a):add(rotEllipse(43, 22, 12, 12, a))
shell:add(rotEllipse(32, 32, 8, 5, a))
local kernel = c:ellipse(13, 50, 5, 4)
local P = c:build{
  { "kernel", kernel, GV.ramp("#a8582f", { rim = "#d9885a" }), { gloss = false } },
  { "shell", shell:copy():cut(c:ellipse(11, 53, 5, 4)), "#dcb06a" },
}
-- net texture: staggered dots
local net = { {18,36},{24,34},{22,42},{28,40},{17,46},{38,20},{44,18},{42,26},{48,24},{37,28},{26,48},{47,30} }
for _, d in ipairs(net) do c:px(d[1], d[2], "#a5663a") end
-- crack line across lower-left tip
c:paint({ "cc......", "..cc....", "....c...", ".....cc.", ".......c" }, 8, 45, { c = "#8a4f2a" })
-- waist groove hint
c:paint({ "g", ".g" }, 30, 35, { g = "#a5663a" })
local t = c:save(O .. "aseprite/ph/peanut.aseprite", O .. "png/ph/peanut.png")
print(GV.report(t))
