local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local pr = GV.ramp("#f8eed2")
local d = 15
local all = c:mask()
local pts = {}
for i = 0, 7 do
  local a = i * math.pi / 4
  local x, y = math.floor(32 + d * math.cos(a) + 0.5), math.floor(32 + d * math.sin(a) + 0.5)
  pts[#pts + 1] = { x, y }
  all:add(c:ellipse(x, y, 5.5))
end
-- paint order: lower-right petals first so upper-left ones sit on top
local order = { 1, 2, 3, 8, 4, 7, 5, 6 }
for _, i in ipairs(order) do
  local p = pts[i]
  local lit = (p[1] + p[2]) < 64
  c:part(c:ellipse(p[1], p[2], 5.5), pr, { light = all, gloss = lit and { p[1] - 3, p[2] - 3 } or false })
end
c:part(c:ellipse(32, 32, 8), GV.ramp("#f2b830"))
for _, q in ipairs({ {35, 34}, {32, 37}, {37, 31}, {30, 34} }) do c:px(q[1], q[2], "#d0862a") end
local t = c:save(O .. "aseprite/ico/ico-daisy.aseprite", O .. "png/ico/ico-daisy.png")
print(GV.report(t))
