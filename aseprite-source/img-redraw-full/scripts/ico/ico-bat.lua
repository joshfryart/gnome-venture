local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local brown = GV.ramp("#6e5646")
local dark = GV.ramp("#4b3a2f")
-- left wing: top edge rises to a pointed tip, scalloped lower edge
local lw = c:poly({ {32,30},{22,24},{12,21},{7,22},{9,29},{11,36},{15,34},{19,39},{23,37},{27,42},{32,44} })
lw:cut(c:ellipse(13,38,3.5,3)):cut(c:ellipse(21,41,3.5,3))
local rw = c:poly({ {32,30},{42,24},{52,21},{57,22},{55,29},{53,36},{49,34},{45,39},{41,37},{37,42},{32,44} })
rw:cut(c:ellipse(51,38,3.5,3)):cut(c:ellipse(43,41,3.5,3))
local body = c:ellipse(32,39,6,8)
local head = c:ellipse(32,29,6.5,6)
head:add(c:poly({ {26,27},{25,17},{31,24} })):add(c:poly({ {38,27},{40,17},{34,24} }))
local p = c:build{
  { "lwing", lw, brown },
  { "rwing", rw, brown },
  { "body", body, dark },
  { "head", head, dark },
}
-- wing ribs
c:line({ {27,32},{12,23} }, 1):each(function(x,y) if lw:has(x,y) then c:px(x,y,"#4b3a2f") end end)
c:line({ {27,34},{17,36} }, 1):each(function(x,y) if lw:has(x,y) then c:px(x,y,"#4b3a2f") end end)
c:line({ {37,32},{52,23} }, 1):each(function(x,y) if rw:has(x,y) then c:px(x,y,"#4b3a2f") end end)
c:line({ {37,34},{47,36} }, 1):each(function(x,y) if rw:has(x,y) then c:px(x,y,"#4b3a2f") end end)
-- inner ears
c:paint({ "p.", "p.", "pp" }, 27, 21, { p = "#8a6a7a" })
c:paint({ ".p", ".p", "pp" }, 36, 21, { p = "#8a6a7a" })
-- belly V
c:paint({ "c...c", ".c.c.", "..c.." }, 30, 37, { c = "#f1e9e4" })
-- eyes
c:eye(28,27,true); c:eye(34,27,true)
-- echo arcs
c:paint({ ".aa", "aa.", "aa.", "aa.", ".aa" }, 18, 13, { a = "#a894dc" })
c:paint({ "aa.", ".aa", ".aa", ".aa", "aa." }, 43, 13, { a = "#a894dc" })
c:paint({ ".a", "a.", "a.", ".a" }, 15, 13, { a = "#a894dc" })
c:paint({ "a.", ".a", ".a", "a." }, 47, 13, { a = "#a894dc" })
local t = c:save(O .. "aseprite/ico/ico-bat.aseprite", O .. "png/ico/ico-bat.png")
print(GV.report(t))
