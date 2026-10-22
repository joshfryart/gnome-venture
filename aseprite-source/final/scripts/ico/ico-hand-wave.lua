local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local function arc(cx, cy, r, a0, a1, w)
  local pts = {}
  for i = 0, 12 do
    local a = math.rad(a0 + (a1 - a0) * i / 12)
    pts[#pts + 1] = { math.floor(cx + r * math.cos(a) + 0.5), math.floor(cy - r * math.sin(a) + 0.5) }
  end
  return c:line(pts, w)
end

local hx, hy = 25, 42
local parts = {
  { "arcIn",  arc(hx, hy, 21, 70, 22, 4), "water" },
  { "arcOut", arc(hx, hy, 29, 72, 26, 4), "water" },
}
local fx = { 15, 20, 25, 30 }
local ft = { 30, 26, 26, 29 }
for i = 1, 4 do
  parts[#parts + 1] = { "f" .. i, c:rrect(fx[i], ft[i], fx[i] + 5, 46, 2), "skin" }
end
parts[#parts + 1] = { "palm",  c:rrect(14, 40, 36, 55, 7), "skin" }
parts[#parts + 1] = { "thumb", c:line({ { 10, 41 }, { 12, 45 }, { 15, 49 } }, 5), "skin" }
local p = c:build(parts)

local t = c:save(O .. "aseprite/ico/ico-hand-wave.aseprite", O .. "png/ico/ico-hand-wave.png")
print(GV.report(t))
