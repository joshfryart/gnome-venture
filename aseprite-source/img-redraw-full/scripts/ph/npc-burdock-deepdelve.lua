local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

local disc = c:ellipse(40, 50, 36, 36)
local coat = c:ellipse(39.5, 101, 34, 25):clip(c:rect(0, 76, 79, 99))
local shirt = c:poly({ {29, 76}, {40, 89}, {52, 76} })
local face = c:ellipse(40, 53, 22, 20)
local muzzle = c:ellipse(39.5, 66, 12, 9.5)
local brim = c:ellipse(40, 40, 35, 5.5)
local crown = c:ellipse(40, 41, 20, 15):cut(c:rect(0, 39, 79, 99))
local band = c:rect(20, 32, 60, 36):clip(crown)

c:build{
  { "disc",   disc,   GV.ramp("#b0bc66"), { gloss = false } },
  { "coat",   coat,   GV.ramp("#d6322b") },
  { "shirt",  shirt,  GV.ramp("#f8eed2"), { flat = true } },
  { "face",   face,   GV.ramp("#8f7060") },
  { "muzzle", muzzle, GV.ramp("#e6d2ae"), { gloss = false } },
  { "brim",   brim,   GV.ramp("#dcb06a") },
  { "crown",  crown,  "gold" },
  { "band",   band,   GV.ramp("#d6322b"), { gloss = false, contact = false } },
}
c:seam({ {21, 34}, {59, 34} })
c:button(38, 77)

-- star nose: pink disc with 8 rays
local pk, ray = "#d9667f", "#f6b8cf"
local R = GV.ramp("#d9667f")
c:fill(c:ellipse(40, 62, 3.5, 3), pk)
c:px(38, 60, R.gloss); c:px(39, 60, R.gloss)
c:fill(c:ellipse(40, 62, 3.5, 3):cut(c:ellipse(39, 61, 3.5, 3)), R.shade)
for _, d in ipairs({ {0,-1}, {0,1}, {-1,0}, {1,0} }) do
  c:px(40 + d[1]*5, 62 + d[2]*5, ray); c:px(40 + d[1]*6, 62 + d[2]*6, ray)
end
for _, d in ipairs({ {-1,-1}, {1,-1}, {-1,1}, {1,1} }) do
  c:px(40 + d[1]*4, 62 + d[2]*4, ray); c:px(40 + d[1]*5, 62 + d[2]*5, ray)
end

-- tiny mole eyes under the brim
c:eye(29, 47, true); c:eye(48, 47, true)
-- gentle mouth
c:paint({ "u...........u", ".uuuuuuuuuuu." }, 34, 70, { u = "umber" })

local t = c:save(O .. "aseprite/ph/npc-burdock-deepdelve.aseprite", O .. "png/ph/npc-burdock-deepdelve.png")
print(GV.report(t))
