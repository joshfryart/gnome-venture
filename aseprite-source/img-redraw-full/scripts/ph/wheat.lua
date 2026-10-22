local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local O = D .. "img-redraw-full/"

-- tilted kernel: rows of a leaning ellipse
local function kernel(cx, cy, rx, ry, tilt)
  local m = c:mask()
  local ca, sa = math.cos(tilt), math.sin(tilt)
  for y = math.floor(cy - ry - 2), math.ceil(cy + ry + 2) do
    for x = math.floor(cx - ry - 2), math.ceil(cx + ry + 2) do
      local dx, dy = x - cx, y - cy
      local u = dx * ca + dy * sa
      local v = -dx * sa + dy * ca
      if (u * u) / (rx * rx) + (v * v) / (ry * ry) <= 1 then m:set(x, y) end
    end
  end
  return m
end

local stalk = c:rect(31, 26, 33, 55)
local leaf = c:poly({ {32, 54}, {27, 50}, {22, 43}, {20, 38}, {25, 41}, {30, 46}, {33, 51} })
local gL = GV.ramp("#f5cf6a")
local gR = GV.ramp("#dcb06a")
local parts = {
  { "stalk", stalk, GV.ramp("#2e5a2c"), { flat = true } },
  { "leaf",  leaf,  GV.ramp("#58a03e"), { gloss = false } },
}
local a = math.rad(25)
for i, y in ipairs({ 38, 30, 22 }) do
  parts[#parts + 1] = { "kr" .. i, kernel(38, y, 3.5, 6, a), gR, { gloss = false } }
  parts[#parts + 1] = { "kl" .. i, kernel(26, y, 3.5, 6, -a), gL, { gloss = (i == 3) and { 24, 18 } or false } }
end
parts[#parts + 1] = { "top", kernel(32, 15, 3.5, 6.5, 0), gL, { gloss = { 31, 11 } } }
local p = c:build(parts)
c:ground(31.5, 57, 13, 2)
local t = c:save(O .. "aseprite/ph/wheat.aseprite", O .. "png/ph/wheat.png")
print(GV.report(t))
