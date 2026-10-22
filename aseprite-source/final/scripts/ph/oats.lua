-- ph/oats : fishbone stalk of oat husks with one leaf
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local O = D .. "img-redraw-full/"

-- rotated ellipse mask (deg clockwise, y down)
local function rell(cx, cy, rx, ry, deg)
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

local goldR = GV.ramp("#f5cf6a")
local tanR  = GV.ramp("#d9a660")
local leaf = c:poly({ {31, 51}, {26, 48}, {20, 45}, {15, 44}, {20, 42}, {26, 44}, {33, 48} })

local parts = {
  { "stem", c:line({ {32, 54}, {32, 20} }, 3), "#6a9a3a", { flat = true } },
  { "leaf", leaf, "moss", { gloss = false } },
  { "top",  rell(32, 13, 4, 7.5, 0), goldR },
}
local husks = {}
for i, y in ipairs({ 23, 31, 39 }) do
  local L = rell(23, y, 3.6, 6.5, 40)
  local Rr = rell(40, y, 3.6, 6.5, -40)
  husks[#husks + 1] = { L, 40, 23, y }
  husks[#husks + 1] = { Rr, -40, 40, y }
  parts[#parts + 1] = { "l" .. i, L, (i % 2 == 1) and goldR or tanR }
  parts[#parts + 1] = { "r" .. i, Rr, (i % 2 == 1) and tanR or goldR }
end
c:build(parts)

-- husk centre lines (1 px) along each long axis
local cl = "#b07a45"
local function centre(cx, cy, deg, len)
  local a = math.rad(deg)
  for t = -len, len - 2 do
    local x = math.floor(cx - t * math.sin(a) + 0.5)
    local y = math.floor(cy + t * math.cos(a) + 0.5)
    c:px(x, y, cl)
  end
end
centre(32, 13, 0, 5)
for _, h in ipairs(husks) do centre(h[3], h[4], h[2], 4) end

local t = c:save(O .. "aseprite/ph/oats.aseprite", O .. "png/ph/oats.png")
print(GV.report(t))
