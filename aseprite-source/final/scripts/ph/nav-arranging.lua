local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local T = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local function flower(cx, cy)
  local m = c:ellipse(cx, cy, 3.5, 3.5)
  for i = 0, 4 do
    local a = -math.pi / 2 + i * 2 * math.pi / 5
    m:add(c:ellipse(cx + math.cos(a) * 3.6, cy + math.sin(a) * 3.6, 3, 3))
  end
  return m
end

local leaves = c:ellipse(18, 36, 5, 2.5):add(c:ellipse(46, 36, 5, 2.5))
local vase = c:poly({ {21, 38}, {44, 38}, {38, 54}, {27, 54} }):add(c:rrect(25, 50, 39, 54, 2))
vase:add(c:rrect(19, 35, 45, 39, 1))

local F = {
  { "fl", 21, 24, "petal" },
  { "fr", 43, 24, GV.ramp("#7b66b4") },
  { "fm", 32, 18, GV.ramp("#e0501f") },
  { "bl", 26, 31, "gold" },
  { "br", 38, 31, GV.ramp("#f6b8cf") },
}
local parts = { { "leaves", leaves, "moss" } }
for _, f in ipairs(F) do parts[#parts + 1] = { f[1], flower(f[2], f[3]), f[4] } end
parts[#parts + 1] = { "vase", vase, "gold" }
c:build(parts)

for _, f in ipairs(F) do
  local cen = (f[1] == "bl") and "#f4f0e0" or "#f5cf6a"
  local sh  = (f[1] == "bl") and "#c9a96e" or "#b8661a"
  if f[1] == "bl" or f[1] == "br" then
    c:paint({ ".cc.", "cccs", "ccss", ".ss." }, f[2] - 1, f[3] - 2, { c = cen, s = sh })
  else
    c:paint({ ".cc.", "cccs", "ccss", ".ss." }, f[2] - 1, f[3] - 1, { c = cen, s = sh })
  end
end
c:seam({ {21, 39}, {43, 39} })

local t = c:save(T .. "aseprite/ph/nav-arranging.aseprite", T .. "png/ph/nav-arranging.png")
print(GV.report(t))
