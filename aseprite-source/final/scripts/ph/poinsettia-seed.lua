local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local heap = c:ellipse(32, 22, 14, 6)
local body = c:rrect(12, 24, 52, 54, 2)
local postL = c:rrect(11, 21, 17, 55, 1)
local postR = c:rrect(47, 21, 53, 55, 1)
local plaque = c:rrect(22, 31, 42, 51, 3)
local cx, cy = 32, 41
local star = c:mask()
for i = 0, 5 do
  local a = -math.pi / 2 + i * math.pi / 3
  local tip = { cx + 8.5 * math.cos(a), cy + 8.5 * math.sin(a) }
  local l = { cx + 3 * math.cos(a - 0.9), cy + 3 * math.sin(a - 0.9) }
  local r = { cx + 3 * math.cos(a + 0.9), cy + 3 * math.sin(a + 0.9) }
  star:add(c:poly({ {cx + 0.5, cy + 0.5}, l, tip, r }))
end
star:add(c:ellipse(cx, cy, 3, 3))
local p = c:build{
  { "heap", heap, GV.ramp("#c9a96e") },
  { "body", body, "wood", { gloss = false } },
  { "postL", postL, GV.ramp("#8a4f2a"), { gloss = false } },
  { "postR", postR, GV.ramp("#8a4f2a"), { gloss = false } },
  { "plaque", plaque, GV.ramp("#f1ece0"), { gloss = false } },
  { "star", star, "red", { gloss = { 29, 36 } } },
}
-- seed flecks
for _, d in ipairs({ {24,19},{29,17},{35,18},{40,20},{27,21},{33,21},{38,17},{22,22} }) do
  c:px(d[1], d[2], "#7a4a1f")
end
-- top rim band
c:fill(c:rect(18, 24, 46, 25), "#d9a660")
-- slat gaps (skip plaque)
for _, y in ipairs({ 31, 39, 47 }) do
  for x = 18, 46 do if not plaque:has(x, y) then c:px(x, y, "#5e2f1e") end end
end
-- centre
c:fill(c:rect(31, 40, 33, 42), "#f5cf6a")
c:px(31, 40, "#fff1c8")
-- nails
for _, d in ipairs({ {14,26},{50,26},{14,51},{50,51},{14,38},{50,38} }) do c:px(d[1], d[2], "#2a1a10") end
local t = c:save(O .. "aseprite/ph/poinsettia-seed.aseprite", O .. "png/ph/poinsettia-seed.png")
print(GV.report(t))
