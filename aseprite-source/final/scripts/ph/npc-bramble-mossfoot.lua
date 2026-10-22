local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

-- spike fan: 14 spikes, alternating dark / light
local cx, cy = 39.5, 50
local N, a0, a1 = 14, 200, -20
local step = (a0 - a1) / (N - 1)
local dark, light = c:ellipse(cx, cy, 22, 20), c:mask()
for i = 0, N - 1 do
  local a = math.rad(a0 - i * step)
  local h = math.rad(step * 0.62)
  local function pt(ang, rx, ry) return { cx + math.cos(ang) * rx, cy - math.sin(ang) * ry } end
  local tipR = (i % 2 == 0) and 1.08 or 1.0
  local tri = c:poly({ pt(a - h, 18, 16), pt(a, 29 * tipR, 28 * tipR), pt(a + h, 18, 16) })
  if i % 2 == 0 then dark:add(tri) else light:add(tri) end
end
light:cut(c:ellipse(cx, cy, 17, 15))

local face = c:ellipse(cx, 56, 17, 15):add(c:ellipse(cx, 49, 18, 8))
local jacket = c:ellipse(cx, 104, 35, 28):cut(c:rect(0, 0, 79, 75))
local collar = c:poly({ {29, 76}, {40, 91}, {51, 76} })
local scarf = c:line({ {27, 75}, {33, 79}, {40, 81}, {47, 79}, {53, 75} }, 6)
local tail = c:poly({ {46, 80}, {53, 80}, {54, 96}, {45, 96} })

c:build{
  { "jacket", jacket, GV.ramp("#58a03e") },
  { "collar", collar, GV.ramp("#2e5a2c"), { gloss = false } },
  { "spikesD", dark, GV.ramp("#4a2a1c") },
  { "spikesL", light, GV.ramp("#b0703a"), { gloss = false } },
  { "face", face, GV.ramp("#f8eed2") },
  { "tail", tail, GV.ramp("#dd3a2a"), { gloss = false } },
  { "scarf", scarf, "red" },
}
-- nose
c:part(c:ellipse(39.5, 62, 3.5, 2.5), GV.ramp("#3a2420"), { flat = true })
c:px(38, 61, "#8a6a5a")
-- smile
c:paint({ "m.....m", ".mmmmm." }, 36, 66, { m = "#2a1a10" })
c:eye(30, 47); c:eye(45, 47)
c:seam({ {28, 76}, {33, 79}, {40, 81}, {47, 79}, {52, 76} })
c:seam({ {49, 84}, {50, 95} })
c:button(38, 92)

local t = c:save(O .. "aseprite/ph/npc-bramble-mossfoot.aseprite", O .. "png/ph/npc-bramble-mossfoot.png")
print(GV.report(t))
