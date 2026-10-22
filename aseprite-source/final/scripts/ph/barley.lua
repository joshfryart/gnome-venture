local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- tilted oval mask
local function tov(cx, cy, rx, ry, deg)
  local m = c:mask()
  local a = math.rad(deg)
  local ca, sa = math.cos(a), math.sin(a)
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x - cx, y - cy
    local u = dx * ca + dy * sa
    local v = -dx * sa + dy * ca
    if (u / rx) ^ 2 + (v / ry) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end

local gL = GV.ramp("#f5cf6a")
local gR = GV.ramp("#dcb06a")

local leaf = c:poly({ {32, 54}, {27, 50}, {21, 46}, {16, 41}, {15, 39}, {19, 40}, {25, 43}, {30, 46}, {33, 49} })

local parts = {
  { "stem", c:rrect(30, 40, 33, 56, 1), "#4a8a3e", { flat = true } },
  { "leaf", leaf, "#6a9a3a" },
  { "awnL", c:line({ {28, 18}, {24, 10} }, 2), "#e8a317", { flat = true } },
  { "awnR", c:line({ {35, 18}, {39, 10} }, 2), "#e8a317", { flat = true } },
  { "awnL2", c:line({ {23, 27}, {18, 19} }, 2), "#e8a317", { flat = true } },
  { "awnR2", c:line({ {40, 27}, {45, 19} }, 2), "#e8a317", { flat = true } },
}
-- grains bottom to top so upper ones overlap lower ones (fishbone)
local ys = { 44, 37, 30 }
for i, y in ipairs(ys) do
  parts[#parts + 1] = { "gR" .. i, tov(37.5, y, 4, 6.5, 28), gR }
  parts[#parts + 1] = { "gL" .. i, tov(26.5, y, 4, 6.5, -28), gL }
end
parts[#parts + 1] = { "tip", tov(32, 23, 4, 7.5, 0), gL, { gloss = { 30, 19 } } }
c:build(parts)

local t = c:save(O .. "aseprite/ph/barley.aseprite", O .. "png/ph/barley.png")
print(GV.report(t))
