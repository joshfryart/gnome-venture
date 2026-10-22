local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local cx, cy = 31.5, 31.5

local disc = c:ellipse(cx, cy, 21, 21)
c:part(disc, "#f1ece0", { pale = true })

-- dotted outer ring (dashes by angle)
local dots = c:mask()
for y = 0, 63 do for x = 0, 63 do
  local dx, dy = x - cx, y - cy
  local r = math.sqrt(dx * dx + dy * dy)
  if r >= 17 and r < 19.2 then
    local a = math.atan(dy, dx) + math.pi
    if math.floor(a / (2 * math.pi) * 24) % 2 == 0 then dots:set(x, y) end
  end
end end
c:fill(dots, "#74462a")
-- inner ring
c:fill(c:ellipse(cx, cy, 15.5, 15.5):cut(c:ellipse(cx, cy, 14.5, 14.5)), "#8a4f2a")

-- tent
local tent = c:poly({ {19, 41}, {27, 24}, {36, 41} })
-- flame teardrop
local flame = c:ellipse(40, 34, 5, 5):add(c:poly({ {35, 34}, {41, 23}, {45.5, 34} }))
local core = c:ellipse(40, 35, 2.5, 2.5):add(c:poly({ {37.5, 35}, {40.5, 29}, {43, 35} }))
c:build{
  { "tent", tent, "wood" },
  { "flame", flame, GV.ramp("#e0501f"), { gloss = false, cres = 2, deep = 1 } },
  { "log1", c:line({ {35, 41}, {44, 38} }, 3), GV.ramp("#8a4f2a"), { flat = true } },
  { "log2", c:line({ {35, 38}, {44, 41} }, 3), GV.ramp("#8a4f2a"), { flat = true } },
}
c:fill(core:cut(c:line({ {35, 41}, {44, 38} }, 3)):cut(c:line({ {35, 38}, {44, 41} }, 3)), "#f08a24")
c:px(39, 32, "#ffd27a"); c:px(40, 31, "#ffd27a")
-- door slit
c:fill(c:rect(27, 31, 28, 40), "#5e2f1e")
local t = c:save(O .. "aseprite/stops/stamp-camp.aseprite", O .. "png/stops/stamp-camp.png")
print(GV.report(t))
