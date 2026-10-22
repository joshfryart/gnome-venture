-- ph/feast-dunewhisper-pilaf : spiced rice dome on a very wide cream plate, gold star on top
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local function star(cx, cy, ro, ri)
  local pts = {}
  for i = 0, 9 do
    local a = -math.pi / 2 + i * math.pi / 5
    local r = (i % 2 == 0) and ro or ri
    pts[#pts + 1] = { cx + r * math.cos(a), cy + r * math.sin(a) }
  end
  return c:poly(pts)
end

local mound = c:ellipse(32, 40, 15, 16):cut(c:rect(0, 43, 63, 63))
mound:add(c:ellipse(32, 41, 15, 3.5))

c:build{
  { "plate", c:ellipse(31.5, 46, 22.5, 8.5), "#d6c9b6", { pale = true } },
  { "well", c:ellipse(31.5, 44, 17.5, 5.5), "#f4f0e0", { gloss = false, pale = true } },
  { "rice", mound, "#f08a24", { gloss = { 22, 28 } } },
  { "star", star(32.5, 13.5, 9, 4), "gold", { gloss = { 30, 11 } } },
}
-- veg bits on the rice
c:spot(c:ellipse(25, 36, 3, 2.5), "#e0501f", "#ff9158")
c:spot(c:ellipse(39, 34, 3, 3), "#7ab55c", "#c8d77a")
c:spot(c:ellipse(32, 28, 2.5, 2), "#e8a317", "#fff1c8")
c:spot(c:ellipse(36, 41, 2, 1.5), "#7ab55c", "#c8d77a")
c:spot(c:ellipse(28, 41, 2, 1.5), "#e0501f", "#ff9158")
-- rice grains
for _, p in ipairs({ {30,33}, {35,30}, {42,39}, {22,40}, {33,37}, {26,31} }) do
  c:px(p[1], p[2], "#f5b860")
end
-- stitch along the lit upper plate rim
c:seam({ {11, 44}, {13, 41}, {18, 39} })

local t = c:save(O .. "aseprite/ph/feast-dunewhisper-pilaf.aseprite", O .. "png/ph/feast-dunewhisper-pilaf.png")
print(GV.report(t))
