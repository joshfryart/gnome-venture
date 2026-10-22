local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

local head = c:ellipse(40, 54, 21, 20)
local tunic = c:ellipse(40, 104, 34, 28):cut(c:rect(0, 0, 79, 75))

-- antennae: curled stalks with club tips
local antL = c:line({ {33, 37}, {30, 28}, {26, 20}, {22, 15}, {19, 13} }, 2)
antL:add(c:rrect(15, 10, 19, 14, 1))
local antR = c:line({ {46, 37}, {49, 28}, {53, 20}, {57, 15}, {60, 13} }, 2)
antR:add(c:rrect(60, 10, 64, 14, 1))

-- stripes clipped to head
local s1 = c:line({ {18, 46}, {26, 42}, {34, 41}, {46, 41}, {54, 42}, {62, 46} }, 4):clip(head)
local s2 = c:line({ {18, 59}, {26, 60}, {34, 61}, {46, 61}, {54, 60}, {62, 59} }, 4):clip(head)
local crown = c:line({ {22, 40}, {27, 36}, {33, 34}, {40, 33}, {47, 34}, {53, 36}, {58, 40} }, 3)

local dark = GV.ramp("#35161f")
local p = c:build{
  { "disc",   c:ellipse(40, 50, 36, 36), "#c3b2ea", { gloss = false } },
  { "wingL",  c:ellipse(18, 38, 11, 7), "#f1ebf8", { contour = "#4a2c1a" } },
  { "wingR",  c:ellipse(62, 38, 11, 7), "#f1ebf8", { contour = "#4a2c1a" } },
  { "antL",   antL, dark, { flat = true } },
  { "antR",   antR, dark, { flat = true } },
  { "tunic",  tunic, "#58a03e" },
  { "collar", c:poly({ {28, 77}, {40, 90}, {52, 77} }), "#2f5a2a", { flat = true } },
  { "head",   head, "gold" },
  { "s1",     s1, dark, { flat = true, contour = false } },
  { "s2",     s2, dark, { flat = true, contour = false } },
  { "crown",  crown, "#58a03e", { flat = true } },
  { "bead",   c:rrect(52, 34, 56, 38, 1), "#2e5a2c", { flat = true } },
}
-- wing veins
c:paint({ "..v..", ".v...", "v...." }, 13, 36, { v = "#c3b2ea" })
c:paint({ "..v..", "...v.", "....v" }, 62, 36, { v = "#c3b2ea" })

c:seam({ {40, 84}, {40, 99} })
c:button(38, 89)
c:eye(30, 50); c:eye(46, 50)
c:paint({ "m.........m", ".mmmmmmmmm." }, 35, 55, { m = "#8a4234" })

local t = c:save(O .. "aseprite/ph/npc-hazel-brambleby.aseprite", O .. "png/ph/npc-hazel-brambleby.png")
print(GV.report(t))
