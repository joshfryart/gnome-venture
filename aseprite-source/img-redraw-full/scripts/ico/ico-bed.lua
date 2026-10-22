local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local wood = GV.ramp("#a27e55")
local head = c:rrect(7,10,16,54,2)
head:add(c:ellipse(11.5,10,4.5,3))
local foot = c:rrect(49,40,57,54,2)
local p = c:build{
  { "head", head, wood },
  { "foot", foot, wood },
  { "legs", c:rect(18,47,21,54):add(c:rect(44,47,47,54)), wood, { flat = true } },
  { "bed", c:rrect(10,33,55,47,3), GV.ramp("#4a8cc0") },
  { "pillow", c:rrect(15,21,33,34,5), GV.ramp("#fffaf0",{rim="#fbe8c0",shade="#e6d3ae",deep="#c9a96e",bounce="#ecd9b4"}) },
  { "fold", c:rrect(34,36,54,40,1), GV.ramp("#8fcbd8"), { flat = true } },
}
c:stitch(p.bed.m, { side = "lit" })
c:seam({ {35,38}, {53,38} }, { free = true })

local t = c:save(O.."aseprite/ico/ico-bed.aseprite", O.."png/ico/ico-bed.png")
print(GV.report(t))
