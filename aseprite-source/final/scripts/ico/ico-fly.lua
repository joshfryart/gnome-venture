local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local function rell(cx, cy, rx, ry, deg)
  local a = math.rad(deg); local ca, sa = math.cos(a), math.sin(a)
  local m = c:mask()
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x - cx, y - cy
    local u = dx * ca + dy * sa; local v = -dx * sa + dy * ca
    if (u / rx) ^ 2 + (v / ry) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local wing = GV.ramp("#bcd8ec")
c:build{
  { "lwing", rell(22.5, 25, 12.5, 6.5, 30), wing },
  { "rwing", rell(41.5, 25, 12.5, 6.5, -30), wing },
  { "abdomen", c:ellipse(32, 37, 7, 12), GV.ramp("#3a2f3a") },
  { "head", c:ellipse(32, 21, 8, 8), GV.ramp("#9c2a1e") },
}
-- abdomen bands (felt segments)
c:seam({ {27, 37}, {37, 37} }); c:seam({ {28, 42}, {36, 42} })
c:eye(27, 19, true); c:eye(35, 19, true)
local t = c:save(O .. "aseprite/ico/ico-fly.aseprite", O .. "png/ico/ico-fly.png")
print(GV.report(t))
