local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 48, h = 48, mode = "icon", margin = 3 }
local cx, cy = 23.5, 20
-- cog: disc plus eight chunky teeth, one part
local cog = c:ellipse(cx, cy, 9, 9)
for i = 0, 7 do
  local a = i * math.pi / 4
  local ux, uy = math.cos(a), math.sin(a)
  local vx, vy = -uy, ux
  local r0, r1, hw = 7, 12.5, 2.6
  cog:add(c:poly({
    { cx + ux * r0 - vx * hw, cy + uy * r0 - vy * hw },
    { cx + ux * r1 - vx * hw, cy + uy * r1 - vy * hw },
    { cx + ux * r1 + vx * hw, cy + uy * r1 + vy * hw },
    { cx + ux * r0 + vx * hw, cy + uy * r0 + vy * hw },
  }))
end
local p = c:build{
  { "cog",   cog, GV.ramp("#d9a660") },
  { "hub",   c:ellipse(cx, cy, 5, 5), "wood", { gloss = false } },
  { "hole",  c:ellipse(cx, cy, 2.5, 2.5), "#3d2a1c", { flat = true, gloss = false } },
  { "plank", c:rrect(8, 32, 39, 37, 1), GV.ramp("#8a4f2a"), { gloss = false } },
}
c:seam({ { 10, 33 }, { 37, 33 } })
c:px(cx - 2, cy - 1, "#5e2f1e")
local t = c:save(O .. "aseprite/stops/workshop.aseprite", O .. "png/stops/workshop.png")
print(GV.report(t))
