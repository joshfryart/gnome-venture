local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

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

-- root: round shoulders, belly widest at y~30, taper to a 2px tail at y 55
local root = c:mask()
for y = 20, 55 do
  local hw
  if y <= 30 then
    local t = (30 - y) / 10
    hw = 15 * math.sqrt(math.max(0, 1 - t * t))
  else
    local t = (y - 30) / 25
    hw = 15 * (1 - t) ^ 1.25
  end
  hw = math.max(hw, 1)
  for x = math.floor(31.5 - hw + 0.5), math.floor(31.5 + hw + 0.5) do root:set(x, y) end
end

local beet = GV.ramp("#8a3a8c", { shade = "#5a2a6e", deep = "#291d4a" })

c:build{
  { "leafL", tov(26, 14, 3.5, 8, -30), "leaf" },
  { "leafR", tov(38, 14, 3.5, 8, 30), "moss" },
  { "root", root, beet, { gloss = { 22, 26 } } },
  { "crown", c:rrect(28, 18, 35, 22, 1), "#4a8a3e" },
}
-- pale ring dashes on the belly
c:fill(c:line({ {23, 33}, {25, 34}, {29, 34} }, 1), "#5a2a6e")
c:fill(c:line({ {33, 41}, {37, 41}, {39, 40} }, 1), "#5a2a6e")
c:fill(c:line({ {28, 47}, {32, 47} }, 1), "#5a2a6e")
-- leaf veins
c:fill(c:line({ {28, 19}, {24, 10} }, 1), "#4a8a3e")
c:fill(c:line({ {36, 19}, {40, 10} }, 1), "#4a8a3e")

local t = c:save(O .. "aseprite/ph/beet.aseprite", O .. "png/ph/beet.png")
print(GV.report(t))
