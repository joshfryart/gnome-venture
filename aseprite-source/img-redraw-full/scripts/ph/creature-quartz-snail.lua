local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- long low foot, tail tapering left, head rising right
local foot = c:poly({ {9,51}, {14,47}, {26,44}, {40,42}, {46,40}, {46,51} })
foot:add(c:rrect(9, 47, 47, 50, 2))
local head = c:rrect(42, 36, 52, 50, 4)
foot:add(head)
-- stalks (behind head top)
local stalkFar = c:line({ {45,38}, {45,32}, {46,27} }, 2)
local stalkNear = c:line({ {49,38}, {50,33}, {51,29} }, 2)
local clubFar = c:rrect(44, 24, 47, 27, 1)
local clubNear = c:rrect(49, 25, 53, 29, 1)
-- crystal cluster shell: tall main crystal + side crystals
local shell = c:poly({ {17,43}, {17,33}, {22,24}, {25,22}, {28,24}, {31,11}, {35,20}, {38,21}, {42,29}, {43,43} })
local p = c:build{
  { "stalkF", stalkFar:add(clubFar), "#6e7685", { flat = true } },
  { "foot", foot, GV.ramp("#8b8f96", { base = "#6e7685" }) },
  { "stalkN", stalkNear:add(clubNear), "#7a8291", { flat = true } },
  { "shell", shell, GV.ramp("#5b6470", { base = "#4a5160" }), { gloss = { 22, 30 } } },
}
-- quartz veins
local V = "#d8d0f5"
c:line({ {24,40}, {27,30}, {31,15} }, 1):each(function(x,y) if p.shell.m:has(x,y) then c:px(x,y,V) end end)
c:line({ {31,15}, {33,28}, {35,40} }, 1):each(function(x,y) if p.shell.m:has(x,y) then c:px(x,y,V) end end)
c:line({ {38,40}, {39,30}, {37,23} }, 1):each(function(x,y) if p.shell.m:has(x,y) then c:px(x,y,V) end end)
local F = "#8f7fc9"
c:line({ {20,32}, {25,24}, {27,30} }, 1):each(function(x,y) if p.shell.m:has(x,y) then c:px(x,y,F) end end)
c:line({ {36,24}, {41,31} }, 1):each(function(x,y) if p.shell.m:has(x,y) then c:px(x,y,F) end end)
-- eye on near stalk tip, mouth line
c:eye(50, 26, true)
c:px(51, 44, "#4a2c1a"); c:px(50, 45, "#4a2c1a")
c:ground(31, 52, 20, 1.5)
local t = c:save(O .. "aseprite/ph/creature-quartz-snail.aseprite", O .. "png/ph/creature-quartz-snail.png")
print(GV.report(t))
