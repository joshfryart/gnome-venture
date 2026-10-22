local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

-- spikes: ring of triangles around the head, alternating light/dark
local light, dark = c:mask(), c:mask()
local cx, cy, rx, ry = 40, 52, 21, 19
local n = 0
for a = 205, -25, -23 do
  local t = math.rad(a)
  local t0, t1 = math.rad(a + 12), math.rad(a - 12)
  local b0 = { cx + math.cos(t0) * (rx - 3), cy - math.sin(t0) * (ry - 3) }
  local b1 = { cx + math.cos(t1) * (rx - 3), cy - math.sin(t1) * (ry - 3) }
  local tip = { cx + math.cos(t) * (rx + 9), cy - math.sin(t) * (ry + 9) }
  local tri = c:poly({ b0, tip, b1, { cx, cy } })
  if n % 2 == 0 then light:add(tri) else dark:add(tri) end
  n = n + 1
end
dark:cut(light)

local coat = c:ellipse(40, 100, 34, 26):cut(c:rect(0, 100, 79, 120))
local scarf = c:line({ {27, 74}, {33, 77}, {40, 78}, {47, 77}, {53, 74} }, 5)
scarf:add(c:poly({ {45, 77}, {52, 77}, {54, 96}, {45, 96} }))
local face = c:ellipse(40, 57, 17, 14):add(c:ellipse(40, 50, 18, 7))
local cone = c:poly({ {17, 39}, {23, 32}, {30, 24}, {37, 16}, {43, 9}, {48, 4}, {50, 6},
                      {53, 13}, {56, 21}, {59, 29}, {62, 35}, {64, 39} })

local p = c:build{
  { "back",  c:ellipse(40, 50, 36, 36), GV.ramp("#f6b8cf"), { gloss = false } },
  { "coat",  coat, GV.ramp("#a5663a") },
  { "spkL",  light, GV.ramp("#8c4a1a"), { flat = true } },
  { "spkD",  dark, GV.ramp("#44281c"), { flat = true } },
  { "head",  c:ellipse(40, 52, 22, 20), GV.ramp("#8c4a1a"), { gloss = false } },
  { "face",  face, "cream" },
  { "scarf", scarf, GV.ramp("#d6322b") },
  { "nose",  c:ellipse(40, 60.5, 3, 2.5), GV.ramp("#4a2c1a"), { gloss = { 39, 59 } } },
  { "brim",  c:ellipse(40, 39, 28, 4.5), GV.ramp("#9c2a1e"), { gloss = false } },
  { "cone",  cone, "red" },
}
-- collar V on the coat
c:fill(c:poly({ {30, 80}, {40, 92}, {50, 80}, {46, 80}, {40, 87}, {34, 80} }):clip(p.coat.m):cut(p.scarf.m), "#8c4a1a")
-- lit stripe on the cone and dark tip notch
c:line({ {23, 34}, {31, 23} }, 1):each(function(x, y) if p.cone.m:has(x, y) then c:px(x, y, "#ff9158") end end)
c:paint({ "nnn" }, 47, 7, { n = "#6b1b2c" })
-- hem stitch along the brim join
c:seam({ {16, 41}, {64, 41} })
c:button(38, 76)
c:eye(30, 48); c:eye(46, 48)
c:paint({ "u...u", ".uuu." }, 38, 65, { u = "umber" })
local t = c:save(O .. "aseprite/ph/npc-indigo-fennelwick.aseprite", O .. "png/ph/npc-indigo-fennelwick.png")
print(GV.report(t))
