local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- tapered pod along a diagonal axis
local ax, ay, bx, by = 11, 47, 50, 19
local function capsule(r0, r1, t0, t1)
  local m = c:mask()
  local dx, dy = bx - ax, by - ay
  local L2 = dx * dx + dy * dy
  for y = 0, 63 do for x = 0, 63 do
    local t = ((x - ax) * dx + (y - ay) * dy) / L2
    if t >= t0 and t <= t1 then
      local px, py = ax + dx * t, ay + dy * t
      local d = math.sqrt((x - px) ^ 2 + (y - py) ^ 2)
      local s = math.sin(math.pi * math.min(1, math.max(0, (t + 0.06) / 1.12)))
      local r = r0 + (r1 - r0) * s
      if d <= r then m:set(x, y) end
    end
  end end
  return m
end
local pod = capsule(2.2, 8.5, -0.06, 1.0)

local cap = c:poly({ {47, 17}, {51, 13}, {55, 17}, {56, 22}, {52, 25}, {47, 22} })
local stub = c:rrect(53, 11, 57, 15, 1)

local p = c:build{
  { "pod",  pod, GV.ramp("#8c4a1a"), { gloss = { 19, 38 } } },
  { "stub", stub, GV.ramp("#4a8a3e"), { flat = true } },
  { "cap",  cap, GV.ramp("#2e5a2c", { base = "#3f6e34" }) },
}

-- crease along the length, offset to the lower side
local cr = c:line({ {15, 46}, {24, 41}, {34, 35}, {43, 28} }, 1)
cr:clip(p.pod.m:shrink(2))
c:fill(cr, "#44281c")
-- small ridge ticks on the pod
c:px(22, 38, "#a8582f"); c:px(30, 33, "#a8582f"); c:px(37, 28, "#a8582f")

local t = c:save(O .. "aseprite/ph/vanilla.aseprite", O .. "png/ph/vanilla.png")
print(GV.report(t))
