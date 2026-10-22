local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

-- antennae: curl out above the hood, ending in clubs
local ant = c:line({ {34,30},{31,22},{27,16},{23,13},{19,13},{17,16},{18,19} }, 2)
ant:add(c:line({ {46,30},{49,22},{53,16},{57,13},{61,13},{63,16},{62,19} }, 2))
local clubs = c:rrect(15,18,18,21,1):add(c:rrect(62,18,65,21,1))

local body = c:ellipse(40, 102, 35, 27):cut(c:rect(0, 0, 79, 75))
local collar = c:poly({ {30,77},{40,91},{50,77} })
local scarf = c:line({ {28,79},{32,82},{36,84},{40,85},{44,84},{48,82},{52,79} }, 5)
scarf:add(c:poly({ {46,82},{53,82},{52,97},{44,97} }))
local head = c:ellipse(40, 55, 21, 20)
local hood = c:poly({ {14,63},{12,52},{14,42},{19,34},{27,28},{40,24},{53,28},{61,34},{66,42},{68,52},{66,63},
  {59,63},{59,54},{56,45},{51,40},{45,41},{40,46},{35,41},{29,40},{24,45},{21,54},{21,63} })

local p = c:build{
  { "ant",    ant,    GV.ramp("#3d2a1c"), { flat = true } },
  { "clubs",  clubs,  "dusk", { flat = true } },
  { "body",   body,   GV.ramp("#3f93b2") },
  { "collar", collar, GV.ramp("#256a80"), { flat = true } },
  { "scarf",  scarf,  GV.ramp("#7a5cc0") },
  { "head",   head,   GV.ramp("#8f7060") },
  { "hood",   hood,   GV.ramp("#7a5cc0", { shade = "#3e2f66" }), { light = hood:copy():add(head) } },
}
c:seam({ {40,25},{40,45} })
c:button(38, 80)
c:eye(30, 50); c:eye(46, 50)
c:paint({ "u.........u", ".u.......u.", "..uuuuuuu.." }, 35, 61, { u = "#2a1a10" })
local t = c:save(O .. "aseprite/ph/npc-quill-rootstock.aseprite", O .. "png/ph/npc-quill-rootstock.png")
print(GV.report(t))
