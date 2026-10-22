-- ph/dragonfly-wing : pink wing pair on a dark spine
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- rotated ellipse mask (angle in degrees, y down)
local function rot(cx, cy, rx, ry, deg)
  local m = c:mask()
  local a = math.rad(deg)
  local ca, sa = math.cos(a), math.sin(a)
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x + 0.5 - cx, y + 0.5 - cy
    local u = dx * ca + dy * sa
    local v = -dx * sa + dy * ca
    if (u / rx) ^ 2 + (v / ry) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end

-- each wing: a big fore lobe sweeping up and a smaller hind lobe below
local lw = rot(21, 25, 13, 7.5, 25):add(rot(22, 36, 11, 5.5, -15))
local rw = c:mask()
lw:each(function(x, y) rw:set(63 - x, y) end)
local spine = c:rrect(29, 17, 34, 48, 2)

local pink = GV.ramp("#e46a9b", { gloss = "#f6b8cf" })
c:build{
  { "lwing", lw, pink, { gloss = { 15, 21 } } },
  { "rwing", rw, pink, { gloss = false } },
}
-- veins: 1px petal-shade lines fanning from the root
local vein = "#c04a7a"
local function v(pts, w) c:fill(c:line(pts, 1):clip(w:shrink(1)), vein) end
v({ {29, 27}, {19, 22}, {11, 22} }, lw)
v({ {29, 28}, {20, 27}, {13, 28} }, lw)
v({ {29, 33}, {21, 36}, {14, 37} }, lw)
v({ {34, 27}, {44, 22}, {52, 22} }, rw)
v({ {34, 28}, {43, 27}, {50, 28} }, rw)
v({ {34, 33}, {42, 36}, {49, 37} }, rw)
-- spine: dark body bar with a rounded head
c:part(spine, GV.ramp("#3e2f66"), { gloss = { 30, 20 } })
c:part(c:ellipse(31.5, 16, 3.5, 3), GV.ramp("#3e2f66"), { gloss = { 30, 14 } })

local t = c:save(O .. "aseprite/ph/dragonfly-wing.aseprite", O .. "png/ph/dragonfly-wing.png")
print(GV.report(t))
