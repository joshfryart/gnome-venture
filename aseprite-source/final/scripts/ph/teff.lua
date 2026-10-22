local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg)
  local ca, sa = math.cos(a), math.sin(a)
  local m = c:mask()
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x - cx, y - cy
    local u = dx * ca + dy * sa
    local v = -dx * sa + dy * ca
    if (u / rx) ^ 2 + (v / ry) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end

local pink = GV.ramp("#e46a9b")
local dred = GV.ramp("#a8241f")
local stemR = GV.ramp("#4a8a3e")
local leafR = GV.ramp("#58a03e")

local parts = {
  { "stem", c:rect(30, 24, 33, 57), stemR },
  { "leaf", oval(28, 46, 3.5, 8, -40), leafR },
  { "crown", oval(31.5, 14, 4, 7, 0), pink },
}
local ys = { 21, 29, 37 }
for i, y in ipairs(ys) do
  parts[#parts + 1] = { "L" .. i, oval(25, y, 4.5, 6.5, -28), pink }
  parts[#parts + 1] = { "R" .. i, oval(38, y, 4.5, 6.5, 28), dred }
end
c:build(parts)

local t = c:save(D .. "img-redraw-full/aseprite/ph/teff.aseprite", D .. "img-redraw-full/png/ph/teff.png")
print(GV.report(t))
