local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- simpler: rotate (x,y) by a: x' = x cos - y sin ; y' = x sin + y cos ; we want top tilt right for +deg
local function pod(cx, cy, rx, ry, deg)
  local a = math.rad(deg)
  local pts = {}
  for i = 0, 35 do
    local t = i / 36 * 2 * math.pi
    local x = rx * math.cos(t)
    local y = ry * math.sin(t)
    -- teardrop: narrower at top
    if y < 0 then x = x * (1 + y / ry * 0.35) end
    local xr = x * math.cos(a) - y * math.sin(a)
    local yr = x * math.sin(a) + y * math.cos(a)
    pts[#pts + 1] = { cx + xr + 0.5, cy + yr + 0.5 }
  end
  return c:poly(pts)
end

local stalk = c:rect(31, 24, 33, 57)
local leaf = pod(24, 47, 3.5, 7, -55)
local L = c:mask(); local R = c:mask()
for i, y in ipairs({ 39, 30, 21 }) do
  local dx = 9 - (i - 1)
  L:add(pod(32 - dx, y, 3.5, 6.5, -42))
  R:add(pod(32 + dx, y, 3.5, 6.5, 42))
end
local top = pod(32, 12, 4, 8, 0)

c:build{
  { "stalk", stalk, GV.ramp("#2f5a2a"), { flat = true } },
  { "leaf", leaf, "moss" },
  { "right", R, GV.ramp("#e0501f") },
  { "left", L, GV.ramp("#f08a24") },
  { "top", top, GV.ramp("#f08a24") },
}
c:ground(32, 58, 7, 1.5)
local t = c:save(O .. "aseprite/ph/fonio.aseprite", O .. "png/ph/fonio.png")
print(GV.report(t))
