local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- tilted, scalloped leaf mask
local function leaf(cx, cy, rx, ry, deg)
  local a = math.rad(deg)
  local ca, sa = math.cos(a), math.sin(a)
  local m = c:mask()
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x - cx, y - cy
    local u = dx * ca + dy * sa
    local v = -dx * sa + dy * ca
    if (u / rx) ^ 2 + (v / ry) ^ 2 <= 1 then m:set(x, y) end
  end end
  -- scallop bumps around the upper two thirds
  for i = 0, 9 do
    local t = math.rad(-150 + i * 26)  -- angle around ellipse, top = -90
    local eu, ev = rx * math.cos(t), ry * math.sin(t)
    local bx = cx + eu * ca - ev * sa
    local by = cy + eu * sa + ev * ca
    m:add(c:ellipse(math.floor(bx + 0.5), math.floor(by + 0.5), 2, 2))
  end
  return m
end

local stems = c:line({ { 20, 38 }, { 31, 50 } }, 3)
stems:add(c:line({ { 44, 38 }, { 33, 50 } }, 3))
stems:add(c:line({ { 32, 36 }, { 32, 54 } }, 3))
stems:add(c:rect(29, 50, 35, 54))
local L = leaf(20, 28, 9, 14, -28)
local R = leaf(44, 28, 9, 14, 28)
local M = leaf(32, 24, 10, 14, 0)
local tie = c:rrect(27, 45, 37, 49, 1)
c:build{
  { "stems", stems, GV.ramp("#c8d77a"), { gloss = false, cres = 2 } },
  { "left", L, GV.ramp("#4a8a3e") },
  { "right", R, GV.ramp("#4a8a3e") },
  { "centre", M, "moss" },
  { "tie", tie, "gold", { cres = 2, gloss = { 29, 46 } } },
}
-- veins
local V = "#2f5a2a"
for y = 14, 36 do c:px(32, y, V) end
c:paint({ "v...", ".v..", "..v." }, 28, 20, { v = V })
c:paint({ "...v", "..v.", ".v.." }, 33, 20, { v = V })
c:paint({ "v...", ".v..", "..v." }, 28, 27, { v = V })
c:paint({ "...v", "..v.", ".v.." }, 33, 27, { v = V })
local function vein(x0, y0, x1, y1)
  local n = math.max(math.abs(x1 - x0), math.abs(y1 - y0))
  for i = 0, n do
    c:px(math.floor(x0 + (x1 - x0) * i / n + 0.5), math.floor(y0 + (y1 - y0) * i / n + 0.5), V)
  end
end
vein(15, 19, 21, 33)
vein(49, 19, 43, 33)
c:seam({ { 28, 47 }, { 37, 47 } }, { free = true })
local t = c:save(O .. "aseprite/ph/spinach.aseprite", O .. "png/ph/spinach.png")
print(GV.report(t))
