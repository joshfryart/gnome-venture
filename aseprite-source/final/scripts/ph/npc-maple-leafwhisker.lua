local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

local disc = c:ellipse(40, 50, 36, 36)
local coat = c:ellipse(40, 100, 34, 24):cut(c:rect(0, 0, 79, 76))
local collar = c:poly({ {28, 76}, {52, 76}, {40, 90} })
local tail = c:poly({ {4, 24}, {12, 26}, {22, 34}, {20, 42}, {12, 38}, {6, 32} })
local head = c:ellipse(40, 50, 24, 23)
head:add(c:ellipse(40, 56, 22, 18))
local chest = c:ellipse(40, 63, 14, 9):clip(head)
local band = c:poly({ {14, 40}, {22, 32}, {32, 28}, {48, 28}, {58, 32}, {66, 40}, {66, 44}, {58, 37}, {48, 33}, {32, 33}, {22, 37}, {14, 44} }):clip(head)
local beak = c:poly({ {35, 51}, {46, 51}, {40, 59} })

c:build{
  { "disc", disc, "#c3b2ea", { gloss = false, contact = false } },
  { "coat", coat, "#a38f80" },
  { "collar", collar, "#8f7060", { flat = true } },
  { "tail", tail, "#8c4a1a", { gloss = false } },
  { "head", head, "wood" },
  { "chest", chest, "cream", { gloss = false, contact = false } },
  { "band", band, "#3f93b2", { gloss = false } },
  { "bead", c:ellipse(57, 34, 3, 3), "#256a80", { flat = true } },
  { "beak", beak, "gold", { gloss = false } },
}
-- tail feather notches
c:line({ {8, 28}, {17, 34} }, 1)
c:px(12, 31, GV.R.wood.deep or "#5e2f1e")
-- placket
c:fill(c:rect(39, 84, 40, 99), "#2a1a10")
c:seam({ {41, 84}, {41, 99} }, { free = true })
c:paint({ ".g.", "ggg", ".g." }, 38, 88, { g = "#e8a317" })
c:paint({ ".g.", "ggg", ".g." }, 38, 94, { g = "#e8a317" })
-- eyes and brows
c:eye(27, 43); c:eye(48, 43)
c:fill(c:line({ {24, 38}, {32, 41} }, 2), "#2a1a10")
c:fill(c:line({ {56, 38}, {48, 41} }, 2), "#2a1a10")

local t = c:save(O .. "aseprite/ph/npc-maple-leafwhisker.aseprite", O .. "png/ph/npc-maple-leafwhisker.png")
print(GV.report(t))
