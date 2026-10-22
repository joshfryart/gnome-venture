local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

-- spike fan: 14 triangles radiating from the head, alternating tones
local fanA = c:ellipse(40, 54, 20, 18)
local fanB = c:mask()
local n = 14
for i = 0, n - 1 do
  local th = math.rad(-28 + i * (236 / (n - 1)))
  local hw = math.rad(7.5)
  local function pt(a, rx, ry) return { 40 + math.cos(a) * rx, 54 - math.sin(a) * ry } end
  local tri = c:poly({ pt(th - hw, 19, 17), pt(th, 36, 34), pt(th + hw, 19, 17) })
  if i % 2 == 0 then fanA:add(tri) else fanB:add(tri) end
end
local clipT = c:rect(0, 18, 79, 99)
fanA:clip(clipT); fanB:clip(clipT)

local coat = c:ellipse(39.5, 100, 34, 24)
local apron = c:poly({ {26, 82}, {54, 82}, {59, 100}, {21, 100} })
local face = c:ellipse(40, 57, 17, 15):add(c:ellipse(40, 50, 18, 8))
local cap = c:ellipse(40, 39, 23, 17):cut(c:rect(0, 39, 79, 99))
cap:add(c:rrect(15, 36, 65, 40, 2))

local p = c:build{
  { "disc",  c:ellipse(40, 50, 36, 36):clip(c:rect(0, 0, 79, 76)), GV.ramp("#f6b8cf"), { gloss = false } },
  { "coat",  coat, GV.ramp("#a5663a") },
  { "apron", apron, GV.ramp("#f8eed2"), { gloss = false } },
  { "fanA",  fanA, GV.ramp("#8c4a1a"), { gloss = { 22, 40 } } },
  { "fanB",  fanB, GV.ramp("#5a3420"), { flat = true } },
  { "face",  face, GV.ramp("#f8eed2") },
  { "cap",   cap, "water", { stitch = { side = "lit" }, gloss = { 26, 27 } } },
}
-- leaf and bud on the cap
c:part(c:poly({ {41, 30}, {50, 26}, {57, 28}, {54, 32}, {44, 33} }), GV.ramp("#256a80"), { flat = true })
c:fill(c:line({ {44, 31}, {53, 28} }, 1), "#3f93b2")
c:part(c:ellipse(39.5, 22.5, 2.5, 2.5):add(c:rect(39, 24, 40, 26)), GV.ramp("#256a80"), { flat = true })

-- collar V and ties
c:fill(c:line({ {30, 78}, {35, 84} }, 2):add(c:line({ {50, 78}, {45, 84} }, 2)), "#8c4a1a")
c:fill(c:line({ {29, 82}, {33, 88} }, 2):add(c:line({ {51, 82}, {47, 88} }, 2)), "#f5cf6a")
c:seam({ {40, 86}, {40, 99} })
c:button(38, 82)

-- face
c:eye(30, 47); c:eye(46, 47)
c:part(c:ellipse(40, 60, 3.5, 2.5), GV.ramp("#3a2418"), { flat = true })
c:px(38, 59, "#7b66b4")
c:paint({ "u.....u", ".uuuuu." }, 37, 64, { u = "umber" })

local t = c:save(B .. "aseprite/ph/npc-bramble-thornwick.aseprite", B .. "png/ph/npc-bramble-thornwick.png")
print(GV.report(t))
