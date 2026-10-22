local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

local coat = c:ellipse(39.5, 102, 34, 26)
local head = c:ellipse(39.5, 58, 22, 19)
local hat = c:poly({ {18, 41}, {49, 7}, {62, 41} })
hat:add(c:ellipse(49, 9, 2.5, 2.5))
local brim = c:ellipse(39.5, 42, 28, 4)
local shirt = c:poly({ {30, 77}, {40, 89}, {50, 77} }):clip(coat)

local p = c:build{
  { "disc",  c:ellipse(39.5, 52, 36), "#b8d8d2", { contour = false, gloss = false } },
  { "coat",  coat, "water", { stitch = { side = "lit" } } },
  { "shirt", shirt, "cream", { flat = true } },
}
-- antennae, out from under the brim
c:limb({ {23, 46}, {16, 40}, {10, 32} }, 2)
c:limb({ {56, 46}, {63, 40}, {69, 32} }, 2)
local clubs = c:rrect(7, 28, 10, 31, 1):add(c:rrect(68, 28, 71, 31, 1))
local q = c:build{
  { "clubs", clubs, "dusk", { flat = true } },
  { "head",  head, "#8f7060" },
  { "hat",   hat,  "#d9667f" },
  { "brim",  brim, "#9c2a1e" },
}
-- shell split line below the brim
c:fill(c:rect(39, 47, 40, 56), "#2a1a10")
-- collar shade along neckline
c:fill(c:line({ {22, 80}, {29, 77} }, 2):add(c:line({ {51, 77}, {58, 80} }, 2)):clip(coat), "#256a80")
-- highlight arc on the wing-case head
c:fill(c:line({ {22, 54}, {23, 50}, {26, 47} }, 2):clip(head), "#b8957f")
c:seam({ {14, 42}, {66, 42} })
c:button(38, 78)
c:eye(28, 50); c:eye(47, 50)
c:paint({ "s.......s", ".sssssss." }, 35, 64, { s = "#2a1a10" })
local t = c:save(O .. "aseprite/ph/npc-haru-pennywhistle.aseprite", O .. "png/ph/npc-haru-pennywhistle.png")
print(GV.report(t))
