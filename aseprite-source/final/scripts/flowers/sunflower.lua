local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-hybrid/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cx, cy = 31.5, 31.5

local function petal(a, r0, rm, r1, hw)
  local ca, sa = math.cos(a), math.sin(a)
  local function P(r, t) return { cx + ca * r - sa * t, cy + sa * r + ca * t } end
  return c:poly({ P(r0, 0), P(rm, -hw), P(r1 - 2, -hw * 0.5), P(r1, 0), P(r1 - 2, hw * 0.5), P(rm, hw) })
end

local N = 12
local back, front = c:mask(), c:mask()
for i = 0, N - 1 do
  local a = (i / N) * 2 * math.pi
  back:add(petal(a, 6, 15, 23, 3.6))
  front:add(petal(a + math.pi / N, 6, 13, 19.5, 3.2))
end
local disc = c:ellipse(cx, cy, 9.5)

local all = back:copy(); all:add(front)
c:build{
  { "back",  back,  GV.ramp("#f0b52a"), { gloss = false, light = all, cres = 3, deep = 1 } },
  { "front", front, GV.ramp("#f8d55e"), { gloss = false, light = all, cres = 3, deep = 1 } },
  { "disc",  disc,  GV.ramp("#6e3f1a", { deep = "#3d2a1c" }), { gloss = { 27, 27 }, cres = 3 } },
}
-- seed spiral
local seeds = { {30,30}, {34,29}, {35,33}, {32,35}, {28,33}, {27,29}, {31,26}, {37,31}, {35,37}, {29,37}, {25,32} }
for _, s in ipairs(seeds) do c:px(s[1], s[2], "#d9a05b") end

local t = c:save(O .. "aseprite/flowers/sunflower.aseprite", O .. "png/flowers/sunflower.png")
print(GV.report(t))
