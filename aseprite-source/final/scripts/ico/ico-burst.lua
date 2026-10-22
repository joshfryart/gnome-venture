local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- 10-point star, uneven spikes: long one up-right, long one down-left
local outerR = { 22, 30, 21, 24, 20, 23, 29, 21, 24, 20 }
local function star(cx, cy, scale, innerR)
  local pts = {}
  for i = 0, 9 do
    local a = math.rad(-90 + i * 36 + 18)
    local ro = outerR[i + 1] * scale
    pts[#pts + 1] = { cx + math.cos(a) * ro, cy + math.sin(a) * ro }
    local b = math.rad(-90 + i * 36 + 36)
    pts[#pts + 1] = { cx + math.cos(b) * innerR * scale, cy + math.sin(b) * innerR * scale }
  end
  return c:poly(pts)
end

local outer = star(32, 32, 0.9, 14)
local inner = star(32, 32, 0.62, 11)
c:build{
  { "burst", outer, GV.ramp("#e8892a") },
  { "core", inner, GV.ramp("#f8eed2"), { pale = true } },
}
local t = c:save(O .. "aseprite/ico/ico-burst.aseprite", O .. "png/ico/ico-burst.png")
print(GV.report(t))
