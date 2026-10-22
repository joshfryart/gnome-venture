local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local light = GV.ramp("#7b66b4", { shade = "#3e2f66", deep = "#291d4a" })
local dark = GV.ramp("#4e3d80")
local function clump(cx, cy, lean)  -- leaning bead clump
  local m = c:ellipse(cx, cy, 4, 4)
  m:add(c:ellipse(cx + lean * 2, cy - 3, 3.5, 3.5))
  m:add(c:ellipse(cx - lean * 1, cy + 3, 3.5, 3))
  return m
end
local parts = {
  { "stalk", c:rect(31, 24, 33, 57), "#2f5a2a", { flat = true } },
  { "leaf", c:poly({ {32, 53}, {27, 50}, {23, 45}, {22, 40}, {26, 42}, {30, 46}, {33, 51} }), "leaf", { gloss = false } },
}
local R = { {40, 21}, {42, 30}, {40, 39} }
for i, q in ipairs(R) do parts[#parts + 1] = { "r" .. i, clump(q[1], q[2], -1), dark } end
local L = { {24, 21}, {22, 30}, {24, 39} }
for i, q in ipairs(L) do parts[#parts + 1] = { "l" .. i, clump(q[1], q[2], 1), light, { gloss = { q[1] - 2, q[2] - 2 } } } end
parts[#parts + 1] = { "top", c:ellipse(32, 14, 4.5, 7), light, { gloss = { 30, 10 } } }
local p = c:build(parts)
c:px(24, 18, "#fff1c8")
local t = c:save(O .. "aseprite/ph/quinoa.aseprite", O .. "png/ph/quinoa.png")
print(GV.report(t))
