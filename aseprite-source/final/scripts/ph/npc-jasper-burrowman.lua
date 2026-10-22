local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }
local body = c:ellipse(39.5, 102, 34, 27)
local head = c:ellipse(39.5, 56, 21, 17)
local shell = c:ellipse(39.5, 42, 29, 27):cut(c:rect(0, 40, 79, 99))
shell:add(c:rrect(7, 37, 72, 45, 3))
local collar = c:poly({ {29, 75}, {40, 87}, {51, 75} })
local p = c:build{
  { "body",   body,   "water", { stitch = { side = "lit" } } },
  { "collar", collar, "cream", { gloss = false } },
  { "head",   head,   "moss" },
  { "shell",  shell,  "wood" },
  { "muzzle", c:ellipse(39.5, 65, 8, 5.5), "cream", { gloss = { 35, 62 } } },
}
-- lapels
c:fill(c:line({ {27, 76}, {39, 88} }, 2), "#256a80")
c:fill(c:line({ {52, 76}, {40, 88} }, 2), "#256a80")
-- shell scutes as stitched seams
c:seam({ {40, 17}, {40, 37} })
c:seam({ {24, 22}, {28, 37} })
c:seam({ {56, 22}, {52, 37} })
c:seam({ {14, 30}, {66, 30} })
c:seam({ {10, 41}, {70, 41} })
c:button(38, 76)
-- brows
c:paint({ ".bbbb", "b...." }, 29, 48, { b = "#2f5a2a" })
c:paint({ "bbbb.", "....b" }, 46, 48, { b = "#2f5a2a" })
c:eye(30, 51); c:eye(45, 51)
c:paint({ "u.....u", ".uuuuu." }, 36, 66, { u = "umber" })
local t = c:save(D .. "img-redraw-hybrid/aseprite/ph/npc-jasper-burrowman.aseprite", D .. "img-redraw-hybrid/png/ph/npc-jasper-burrowman.png")
print(GV.report(t))
