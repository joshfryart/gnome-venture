local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local stems = c:line({ {32, 55}, {26, 42}, {17, 28} }, 2)
stems:add(c:line({ {32, 55}, {32, 22} }, 2))
stems:add(c:line({ {32, 55}, {38, 42}, {47, 28} }, 2))

local function trefoil(a, b, d, r)
  local m = c:ellipse(a[1], a[2], r)
  m:add(c:ellipse(b[1], b[2], r)); m:add(c:ellipse(d[1], d[2], r))
  return m
end
local L = trefoil({ 12, 24 }, { 18, 18 }, { 20, 27 }, 5)
local M = trefoil({ 27, 13 }, { 37, 13 }, { 32, 20 }, 5)
local R = trefoil({ 44, 27 }, { 46, 18 }, { 52, 24 }, 5)

local p = c:build{
  { "stems", stems, "moss", { flat = true } },
  { "left", L, "moss" },
  { "right", R, "moss" },
  { "mid", M, GV.ramp("#a4b86a") },
  { "knot", c:rrect(30, 52, 34, 56, 1), GV.ramp("#2f5a2a") },
}
local n = "#4a8a3e"
-- notch lines between lobes (toward leaf centre)
c:line({ {16, 23}, {13, 21} }, 1); c:px(16, 23, n); c:px(15, 22, n); c:px(14, 21, n)
c:px(17, 24, n); c:px(18, 25, n)
c:px(32, 13, n); c:px(32, 14, n); c:px(32, 15, n); c:px(30, 16, n); c:px(34, 16, n)
c:px(48, 23, n); c:px(49, 22, n); c:px(47, 25, n); c:px(46, 26, n); c:px(50, 21, n)

local t = c:save(O .. "aseprite/ph/coriander.aseprite", O .. "png/ph/coriander.png")
print(GV.report(t))
