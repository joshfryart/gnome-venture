local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local function rell(cx, cy, rx, ry, deg)
  local m = c:mask(); local a = math.rad(deg); local ca, sa = math.cos(a), math.sin(a)
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x - cx, y - cy
    local u = dx * ca + dy * sa; local v = -dx * sa + dy * ca
    if (u / rx) ^ 2 + (v / ry) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local L = GV.ramp("#a4b86a"); local R = GV.ramp("#7ab55c")
local parts = {
  { "stalk", c:rect(31, 18, 32, 51), "#6a9a3a", { flat = true } },
  { "leaf", c:line({ {31, 47}, {27, 46}, {23, 43}, {21, 40} }, 2), "#4a8a3e", { flat = true } },
}
local ys = { 23, 32, 41 }
for i, y in ipairs(ys) do
  local sh = (i % 2 == 0) and 1 or 0
  parts[#parts + 1] = { "pl" .. i, rell(24.5, y, 3, 6, 40), (i % 2 == 1) and L or R }
  parts[#parts + 1] = { "pr" .. i, rell(38.5, y + 1, 3, 6, -40), (i % 2 == 1) and R or L }
end
parts[#parts + 1] = { "bud", c:ellipse(31.5, 16, 3.5, 5.5), L }
c:build(parts)
-- pod ridge lines
for i, y in ipairs(ys) do
  c:line({ {26, y - 3}, {25, y + 2} }, 1)
  c:px(26, y - 3, "#4a8a3e"); c:px(26, y - 2, "#4a8a3e"); c:px(25, y + 1, "#4a8a3e"); c:px(25, y + 2, "#4a8a3e")
  c:px(37, y - 2, "#2f5a2a"); c:px(37, y - 1, "#2f5a2a"); c:px(38, y + 2, "#2f5a2a"); c:px(38, y + 3, "#2f5a2a")
end
c:px(31, 13, "#4a8a3e"); c:px(32, 13, "#4a8a3e"); c:px(31, 14, "#4a8a3e")
local P = GV.ramp("#f1ece0")
local seeds = { {22, 51}, {26, 52}, {30, 52}, {34, 52}, {38, 51}, {28, 50}, {36, 50}, {42, 52} }
for _, s in ipairs(seeds) do
  c:part(c:rect(s[1], s[2], s[1] + 2, s[2] + 1), P, { flat = true })
end
local t = c:save(O .. "aseprite/ph/sesame.aseprite", O .. "png/ph/sesame.png")
print(GV.report(t))
