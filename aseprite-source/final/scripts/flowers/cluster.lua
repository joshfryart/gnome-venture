local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local C = {
  {32,14}, {21,19}, {43,19}, {32,26}, {13,29}, {24,29}, {40,29}, {51,29},
  {17,40}, {28,40}, {36,40}, {47,40}, {22,50}, {32,49}, {42,50},
}
local ramps = { GV.ramp("#e46a9b"), GV.ramp("#e46a9b"), GV.ramp("#f6b8cf") }
local alt = { GV.ramp("#e46a9b"), GV.ramp("#c0527f"), GV.ramp("#e46a9b") }
local all = c:mask()
local list = {}
for i, p in ipairs(C) do
  local x = 31.5 + (p[1] - 32) * 0.8
  local y = 31 + (p[2] - 32) * 0.8
  local m = c:ellipse(math.floor(x) + 0.5, math.floor(y), 6.5, 6)
  all:add(m)
  local r = (i % 3 == 0) and ramps[3] or ((i % 6 == 2) and alt[2] or ramps[1])
  list[#list + 1] = { "b" .. i, m, r, { light = nil } }
end
c:build(list)
local t = c:save(O .. "aseprite/flowers/cluster.aseprite", O .. "png/flowers/cluster.png")
print(GV.report(t))
