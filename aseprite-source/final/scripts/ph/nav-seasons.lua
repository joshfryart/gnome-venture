local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local cx, cy = 24, 24
local rays = c:mask()
for i = 0, 7 do
  local a = i * math.pi / 4
  local dx, dy = math.cos(a), math.sin(a)
  rays:add(c:line({ { math.floor(cx + dx * 11 + 0.5), math.floor(cy + dy * 11 + 0.5) },
                    { math.floor(cx + dx * 15 + 0.5), math.floor(cy + dy * 15 + 0.5) } }, 3))
end
local sun = c:ellipse(cx, cy, 9, 9)
local back = c:ellipse(47, 43, 6, 6)
local cloud = c:ellipse(38, 39, 9, 9)
cloud:add(c:ellipse(28, 43, 6, 6))
cloud:add(c:rrect(22, 41, 50, 50, 4))

c:build{
  { "rays",  rays,  GV.ramp("#f5cf6a"), { flat = true } },
  { "sun",   sun,   "gold" },
  { "back",  back,  GV.ramp("#d6c9b6") },
  { "cloud", cloud, GV.ramp("#f4f0e0") },
}

local t = c:save(O .. "aseprite/ph/nav-seasons.aseprite", O .. "png/ph/nav-seasons.png")
print(GV.report(t))
