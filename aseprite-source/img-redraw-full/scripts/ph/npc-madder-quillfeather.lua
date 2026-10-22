local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }
local tan  = GV.ramp("#dcb06a")
local rose = GV.ramp("#d9667f")
local teal = GV.ramp("#b8d8d2")
local pink = GV.ramp("#f6b8cf")

-- hood: big arch with a face opening, sides ending at the cheeks
local hood = c:ellipse(39.5, 50, 28, 27):cut(c:rect(0, 66, 79, 99))
hood:cut(c:ellipse(39.5, 57, 17, 15))
hood:cut(c:poly({ {23, 66}, {56, 66}, {50, 72}, {29, 72} }))

local coat = c:ellipse(39.5, 100, 34, 25)
local bib = c:poly({ {27, 80}, {53, 80}, {58, 100}, {22, 100} })

local p = c:build{
  { "back",  c:ellipse(39.5, 50, 36, 36):cut(c:rect(0, 86, 79, 99)), teal, { gloss = false, solid = true } },
  { "coat",  coat, rose, { stitch = { side = "lit" } } },
  { "bib",   bib, "cream" },
  { "earL",  c:ellipse(17, 26, 9, 9), tan },
  { "earR",  c:ellipse(62, 26, 9, 9), tan },
  { "head",  c:ellipse(39.5, 56, 20, 18), tan },
  { "muzz",  c:ellipse(39.5, 62, 11, 8), "cream", { gloss = false } },
  { "hood",  hood, "gold", { stitch = { side = "lit" } } },
}
-- inner ears
c:fill(c:ellipse(16, 25, 5, 5), pink.base)
c:fill(c:ellipse(15, 24, 2, 2), pink.gloss)
c:fill(c:ellipse(61, 25, 5, 5), pink.base)
c:fill(c:ellipse(60, 24, 2, 2), pink.gloss)
-- collar tabs
c:part(c:line({ {29, 77}, {33, 84} }, 3), "cream", { flat = true })
c:part(c:line({ {50, 77}, {46, 84} }, 3), "cream", { flat = true })
-- bib seams
c:seam({ {26, 82}, {22, 99} })
c:seam({ {54, 82}, {58, 99} })
c:button(37, 86)
-- face
c:eye(29, 50); c:eye(46, 50)
c:fill(c:ellipse(39.5, 59, 3.5, 2.5), rose.base)
c:px(38, 58, rose.gloss); c:px(39, 58, rose.gloss)
c:paint({ "u.....u", ".uuuuu." }, 36, 64, { u = "umber" })
c:paint({ "uuuu", "....", "uuu" }, 25, 61, { u = "umber" })
c:paint({ "uuuu", "....", ".uuu" }, 51, 61, { u = "umber" })

local t = c:save(O .. "aseprite/ph/npc-madder-quillfeather.aseprite", O .. "png/ph/npc-madder-quillfeather.png")
print(GV.report(t))
