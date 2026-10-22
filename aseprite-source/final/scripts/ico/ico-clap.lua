local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local function cap(cx, cy, r, hl, deg)
  local a = math.rad(deg); local ux, uy = math.sin(a), -math.cos(a)
  local m = c:mask()
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x - cx, y - cy
    local t = math.max(-hl, math.min(hl, dx*ux + dy*uy))
    local ex, ey = dx - t*ux, dy - t*uy
    if ex*ex + ey*ey <= r*r then m:set(x, y) end
  end end
  return m
end
local function at(cx, cy, deg, along, across)
  local a = math.rad(deg); local ux, uy = math.sin(a), -math.cos(a)
  return math.floor(cx + along*ux - across*uy + 0.5), math.floor(cy + along*uy + across*ux + 0.5)
end
local Lr, Rr = GV.ramp("#d9a477"), GV.ramp("#e9b98a")
local L = cap(22.5, 36, 6.5, 10, 20)
local R = cap(41.5, 36, 6.5, 10, -20)
local p = c:build{
  { "left", L, Lr },
  { "lthumb", cap(28, 41, 2.5, 3.5, 28), Lr, { gloss = false } },
  { "right", R, Rr },
  { "rthumb", cap(36, 41, 2.5, 3.5, -28), Rr, { gloss = false } },
}
local function crease(cx, cy, deg, across, hex, m)
  for s = 0, 9 do local x, y = at(cx, cy, deg, 2 + s, across); if m:has(x,y) then c:px(x, y, hex) end end
end
for _, k in ipairs({ -3, 0, 3 }) do
  crease(22.5, 36, 20, k, Lr.shade, p.left.m)
  crease(41.5, 36, -20, k, Rr.shade, p.right.m)
end
local gold = GV.ramp("#f2cf4a")
c:part(c:line({ {31,11}, {31,17} }, 3), gold, { flat = true })
c:part(c:line({ {15,15}, {19,20} }, 3), gold, { flat = true })
c:part(c:line({ {47,15}, {43,20} }, 3), gold, { flat = true })
local t = c:save(O .. "aseprite/ico/ico-clap.aseprite", O .. "png/ico/ico-clap.png")
print(GV.report(t))
