local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local rice = c:ellipse(32, 32, 20, 21):cut(c:rect(0, 33, 63, 63))
local bowl = c:ellipse(32, 31, 25, 22):cut(c:rect(0, 0, 63, 31))
local rim = c:rrect(7, 29, 57, 35, 3)

-- tilted sauce ellipse: built from rows
local sauce = c:mask()
local cx, cy, rx, ry, a = 33, 21, 14, 7, math.rad(-12)
for y = 0, 63 do for x = 0, 63 do
  local dx, dy = x - cx, y - cy
  local u = dx * math.cos(a) + dy * math.sin(a)
  local v = -dx * math.sin(a) + dy * math.cos(a)
  if (u / rx) ^ 2 + (v / ry) ^ 2 <= 1 then sauce:set(x, y) end
end end
-- drips down the rice
sauce:add(c:rrect(20, 22, 23, 30, 1))
sauce:add(c:rrect(40, 22, 43, 30, 1))
sauce:clip(rice)

c:build{
  { "rice",  rice,  GV.ramp("#f8eed2") },
  { "sauce", sauce, GV.ramp("#c4601c"), { gloss = { 22, 19 } } },
  { "bowl",  bowl,  GV.ramp("#3f93b2") },
  { "rim",   rim,   GV.ramp("#dcb06a") },
  { "chunkA", c:rrect(37, 15, 43, 23, 2), GV.ramp("#d68e4e", { rim = "#f0d49a" }) },
  { "chunkB", c:rrect(26, 19, 32, 26, 2), GV.ramp("#d68e4e", { rim = "#f0d49a" }) },
}

c:seam({ {10, 32}, {28, 32} }); c:seam({ {49, 32}, {55, 32} })

local t = c:save(O .. "aseprite/ico/ico-curry.aseprite", O .. "png/ico/ico-curry.png")
print(GV.report(t))
