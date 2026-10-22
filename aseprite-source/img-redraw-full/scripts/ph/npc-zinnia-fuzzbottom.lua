local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }
local dark = GV.ramp("#3b2a30")
local head = c:ellipse(40, 56, 21, 19)
local s1 = c:rect(0, 46, 79, 50):clip(head)
local s2 = c:rect(0, 59, 79, 63):clip(head)
local cone = c:poly({ {17, 42}, {46, 7}, {64, 42} })
local p = c:build{
  { "disc",  c:ellipse(40, 50, 36, 36), "#dcb06a", { gloss = false } },
  { "body",  c:rrect(6, 72, 73, 112, 14), "gold" },
  { "collar", c:poly({ {29, 73}, {40, 88}, {51, 73} }), "#b07a10", { flat = true } },
  { "wingL", c:ellipse(16, 40, 9, 6), "#fff3c8" },
  { "wingR", c:ellipse(63, 40, 9, 6), "#fff3c8" },
  { "antL",  c:line({ {33, 40}, {29, 33}, {25, 28}, {22, 25} }, 2):add(c:rrect(18, 20, 22, 24, 1)), dark, { flat = true } },
  { "antR",  c:line({ {47, 40}, {51, 33}, {55, 28}, {58, 25} }, 2):add(c:rrect(58, 20, 62, 24, 1)), dark, { flat = true } },
  { "head",  head, "gold" },
  { "s1",    s1, dark, { gloss = false } },
  { "s2",    s2, dark, { gloss = false } },
  { "cone",  cone, "#d9667f" },
  { "brim",  c:ellipse(40, 42, 26, 3.5), "#9c2a1e", { gloss = false } },
  { "nub",   c:ellipse(46.5, 7.5, 3, 3), "cream" },
}
c:seam({ {16, 42}, {64, 42} })
c:eye(29, 53); c:eye(47, 53)
c:paint({ "u.........u", ".uuuuuuuuu." }, 35, 66, { u = "umber" })
local t = c:save(O .. "aseprite/ph/npc-zinnia-fuzzbottom.aseprite", O .. "png/ph/npc-zinnia-fuzzbottom.png")
print(GV.report(t))
