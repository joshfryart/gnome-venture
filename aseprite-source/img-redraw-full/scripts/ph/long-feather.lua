local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- vane: leaf along the axis base (16,52) -> tip (50,8), fuller on the upper-left side
local bx, by, tx, ty = 16, 52, 50, 8
local dx, dy = tx - bx, ty - by
local L = math.sqrt(dx * dx + dy * dy)
local ux, uy = dx / L, dy / L
local px, py = uy, -ux            -- perpendicular toward upper-left
local left, right = {}, {}
local N = 16
for i = 0, N do
  local t = i / N
  local ax, ay = bx + dx * t, by + dy * t
  local s = math.sin(math.pi * (t ^ 0.8))
  local wl = 11.5 * s
  local wr = 6.5 * s
  left[#left + 1] = { ax + px * wl, ay + py * wl }
  table.insert(right, 1, { ax - px * wr, ay - py * wr })
end
local pts = {}
for _, p in ipairs(left) do pts[#pts + 1] = p end
for _, p in ipairs(right) do pts[#pts + 1] = p end
local vane = c:poly(pts)
-- three notches cut into the upper-left edge (split barbs)
local function notch(t, side, depth)
  local ax, ay = bx + dx * t, by + dy * t
  local ex, ey = ax + px * side * 13, ay + py * side * 13
  local ix, iy = ax + px * side * depth - ux * 3, ay + py * side * depth - uy * 3
  vane:cut(c:poly({ { ex + ux * 0.5, ey + uy * 0.5 }, { ex + ux * 5, ey + uy * 5 }, { ix, iy } }))
end
notch(0.30, 1, 4)
notch(0.55, 1, 4)
notch(0.40, -1, 2.5)

local shaftA = c:line({ { 14, 56 }, { 29, 36 } }, 3)
local shaftB = c:line({ { 29, 36 }, { 45, 15 } }, 3)

local p = c:build{
  { "vane", vane, "petal", { gloss = { 22, 22 } } },
  { "shaftLo", shaftA, "#c66b50", { flat = true } },
  { "shaftHi", shaftB, GV.ramp("#f0d49a", { gloss = "#fff3c8" }), { flat = true } },
}
-- barb lines: thin dark hatch along the vane, angled back toward the base
local function barb(x0, y0, x1, y1)
  c:fill(c:line({ { x0, y0 }, { x1, y1 } }, 1):clip(p.vane.m):cut(shaftA):cut(shaftB), "#6b1b2c")
end
barb(24, 30, 31, 33)
barb(30, 22, 37, 25)
barb(38, 34, 34, 30)
-- quill nib
c:fill(c:rect(12, 55, 14, 57), "#8a4234")
c:px(12, 55, "#c66b50")
local t = c:save(O .. "aseprite/ph/long-feather.aseprite", O .. "png/ph/long-feather.png")
print(GV.report(t))
