local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }
local stick = GV.ramp("#5e2f1e")
local disc = c:ellipse(39.5, 52, 33, 33)
local coat = c:ellipse(39.5, 102, 34, 26):clip(c:rect(0, 76, 79, 99))
local antL = c:line({ {36, 24}, {33, 15}, {28, 9}, {21, 8}, {16, 11}, {16, 15} }, 2):add(c:rrect(17, 15, 20, 18, 1))
local antR = c:line({ {43, 24}, {46, 15}, {51, 9}, {58, 8}, {63, 11}, {63, 15} }, 2):add(c:rrect(59, 15, 62, 18, 1))
local head = c:ellipse(39.5, 47, 10.5, 23)
local shawl = c:ellipse(39.5, 47, 20, 26)
shawl:add(c:poly({ {19, 58}, {61, 58}, {71, 86}, {54, 81}, {40, 88}, {26, 81}, {9, 86} }))
shawl:cut(c:ellipse(39.5, 50, 10, 16))
shawl:cut(c:poly({ {36, 65}, {44, 65}, {40, 72} }))
local p = c:build{
  { "disc", disc, "#dcb06a" },
  { "coat", coat, "#d9667f" },
  { "antL", antL, stick, { flat = true } },
  { "antR", antR, stick, { flat = true } },
  { "head", head, "wood" },
  { "shawl", shawl, "#7a5cc0", { stitch = true } },
}
-- twig ridge and bark nicks
local D = "#2a1a10"
c:fill(c:rect(39, 35, 40, 40), D)
c:fill(c:line({ {31, 52}, {32, 54} }, 1), D)
c:fill(c:line({ {48, 50}, {47, 52} }, 1), D)
c:eye(33, 42); c:eye(43, 42)
c:paint({ "u....u", ".uuuu." }, 37, 57, { u = D })
c:button(38, 72)
c:seam({ {40, 89}, {40, 99} })
local t = c:save(O .. "aseprite/ph/npc-old-twigg.aseprite", O .. "png/ph/npc-old-twigg.png")
print(GV.report(t))
