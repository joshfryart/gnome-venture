local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg)
  local ca, sa = math.cos(a), math.sin(a)
  local m = c:mask()
  for y = 0, 63 do for x = 0, 63 do
    local px, py = x + 0.5 - cx, y + 0.5 - cy
    local u = px * ca + py * sa
    local v = -px * sa + py * ca
    if (u / rx) ^ 2 + (v / ry) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local orange = GV.ramp("#f08a24")
local redor = GV.ramp("#e0501f")
local stalk = c:rect(30, 28, 32, 55)
local leaf = c:poly({ {31,51}, {26,48}, {21,43}, {18,37}, {19,35}, {23,39}, {28,43}, {31,45} })
local head = c:mask()
local parts = {
  { "stalk", stalk, GV.ramp("#2e5a2c", { base = "#2f5a2a", rim = "#4a8a3e", gloss = "#6a9a3a" }), { cres = 1, deep = 0 } },
  { "leaf", leaf, GV.ramp("#58a03e"), { gloss = { 21, 38 } } },
}
local grains = {
  { "l3", oval(25, 39, 4.5, 6.5, -25), orange },
  { "r3", oval(37, 39, 4.5, 6.5, 25), redor },
  { "l2", oval(24.5, 31.5, 5, 7, -25), orange },
  { "r2", oval(37.5, 31.5, 5, 7, 25), redor },
  { "l1", oval(25, 23.5, 4.5, 6.5, -25), orange },
  { "r1", oval(37, 23.5, 4.5, 6.5, 25), redor },
  { "crown", oval(31, 17, 4.5, 7.5, 0), orange },
}
for _, g in ipairs(grains) do head:add(g[2]) end
for _, g in ipairs(grains) do
  parts[#parts + 1] = { g[1], g[2], g[3], { light = head } }
end
c:build(parts)
local t = c:save(O .. "aseprite/ph/sorghum.aseprite", O .. "png/ph/sorghum.png")
print(GV.report(t))
