-- ico/ico-sun : round gold disc ringed by 8 chunky wedge rays (long cardinal, short diagonal)
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local cx, cy = 31.5, 31.5

local rays = c:mask()
for i = 0, 7 do
  local a = i * math.pi / 4
  local long = (i % 2 == 0)
  local R  = long and 23 or 19
  local hw = long and 3.5 or 3
  local tw = 1.5
  local dx, dy = math.cos(a), math.sin(a)
  local px, py = -dy, dx
  local b = 10
  rays:add(c:poly({
    { cx + dx*b + px*hw, cy + dy*b + py*hw },
    { cx + dx*R + px*tw, cy + dy*R + py*tw },
    { cx + dx*R - px*tw, cy + dy*R - py*tw },
    { cx + dx*b - px*hw, cy + dy*b - py*hw },
  }))
end

c:build{
  { "rays", rays, "gold", { gloss = false } },
  { "disc", c:ellipse(cx, cy, 12), GV.ramp("#f2b830") },
}

local t = c:save(O .. "aseprite/ico/ico-sun.aseprite", O .. "png/ico/ico-sun.png")
print(GV.report(t))
