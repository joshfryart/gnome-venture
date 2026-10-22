local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }
local blue = GV.ramp("#3f93b2")
-- body (coat) bleeding off bottom
local body = c:ellipse(39.5, 102, 34, 23)
-- split shell-cape: arch behind head flaring to both sides
local shell = c:ellipse(39.5, 50, 28, 27):cut(c:rect(0, 60, 79, 99))
shell:add(c:poly({ {12, 58}, {67, 58}, {69, 86}, {48, 84}, {39.5, 74}, {31, 84}, {10, 86} }))
shell:add(c:poly({ {12, 50}, {20, 50}, {16, 86}, {11, 80} }))
shell:add(c:poly({ {59, 50}, {68, 50}, {68, 80}, {63, 86} }))
-- antennae with clubs
local ant = c:line({ {35, 36}, {28, 17} }, 2):add(c:line({ {44, 36}, {51, 17} }, 2))
ant:add(c:rrect(25, 13, 29, 17, 1)):add(c:rrect(50, 13, 54, 17, 1))
local head = c:ellipse(39.5, 53, 18, 17)
local bib = c:poly({ {28, 80}, {52, 80}, {57, 100}, {23, 100} })
local flaps = c:poly({ {27, 78}, {39, 78}, {33, 87} }):add(c:poly({ {41, 78}, {53, 78}, {47, 87} }))
local p = c:build{
  { "body",  body,  GV.ramp("#2f6a8a"), { stitch = { side = "lit" } } },
  { "shell", shell, blue },
  { "ant",   ant,   GV.ramp("#4a2c1a"), { flat = true } },
  { "head",  head,  "wood" },
  { "bib",   bib,   "cream", { gloss = false } },
  { "flaps", flaps, "cream", { gloss = false } },
}
-- shell split line from top of arch down to head
c:fill(c:rect(39, 23, 40, 35), "#256a80")
-- gold seam along the shell arch
local pts = {}
for a = 200, 340, 10 do
  local r = math.rad(a)
  pts[#pts + 1] = { math.floor(39.5 + 24 * math.cos(r) + 0.5), math.floor(50 + 23 * math.sin(r) + 0.5) }
end
c:seam(pts)
c:button(38, 89)
-- face
c:eye(30, 49); c:eye(45, 49)
c:paint({ "u......u", ".uuuuuu." }, 36, 61, { u = "umber" })
local t = c:save(O .. "aseprite/ph/npc-rowan-burrowman.aseprite", O .. "png/ph/npc-rowan-burrowman.png")
print(GV.report(t))
