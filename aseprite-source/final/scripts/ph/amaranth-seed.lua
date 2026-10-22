local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- round-bottom sack: narrower at neck, wide belly
local body = c:poly({ {20, 19}, {44, 19}, {50, 30}, {52, 42}, {12, 42}, {14, 30} })
body:add(c:ellipse(32, 44, 20, 12))
body:cut(c:rect(0, 57, 63, 63))
local frill = c:poly({ {15, 10}, {49, 10}, {43, 20}, {21, 20} })
frill:add(c:ellipse(18, 11, 3, 2)):add(c:ellipse(32, 10, 3, 2)):add(c:ellipse(46, 11, 3, 2))
local cinch = c:rrect(18, 17, 46, 20, 1)
local patch = c:rrect(21, 27, 43, 49, 6)
local leaf = c:poly({ {32, 30}, {37, 34}, {38, 40}, {36, 45}, {32, 48}, {28, 45}, {26, 40}, {27, 34} })

local p = c:build{
  { "body",  body,  "#f1ece0" },
  { "frill", frill, "#f1ece0", { contact = true } },
  { "cinch", cinch, "#dcb06a", { flat = true } },
  { "patch", patch, "#f4f0e0", { gloss = false } },
  { "leaf",  leaf,  "#58a03e", { gloss = { 29, 34 } } },
}
-- frill fold lines
c:fill(c:line({ {25, 12}, {27, 17} }, 1), "#c9a96e")
c:fill(c:line({ {39, 12}, {37, 17} }, 1), "#c9a96e")
-- leaf vein
c:fill(c:line({ {32, 32}, {32, 46} }, 1), "#2f5a2a")
c:px(31, 39, "#2f5a2a"); c:px(30, 38, "#2f5a2a"); c:px(33, 42, "#2f5a2a"); c:px(34, 41, "#2f5a2a")
-- edge stitch around patch
c:stitch(p.patch.m)
-- drawstring bow loops and hanging ends
local bow = GV.R.gold
c:fill(c:ellipse(24, 21, 3, 2):cut(c:ellipse(24, 21, 1, 0.5)), "#e8a317")
c:fill(c:ellipse(40, 21, 3, 2):cut(c:ellipse(40, 21, 1, 0.5)), "#e8a317")
c:fill(c:line({ {29, 22}, {27, 28} }, 2), "#e8a317")
c:fill(c:line({ {34, 22}, {36, 28} }, 2), "#b8661a")
c:button(30, 17)
-- seeds
c:fill(c:ellipse(26, 53, 1.5, 1.5), "#8c4a1a")
c:fill(c:ellipse(32, 53, 1.5, 1.5), "#8c4a1a")
c:fill(c:ellipse(38, 53, 1.5, 1.5), "#8c4a1a")
c:px(25, 52, "#c97a3a"); c:px(31, 52, "#c97a3a"); c:px(37, 52, "#c97a3a")
c:ground(32, 57, 16, 1.5)

local t = c:save(D .. "img-redraw-full/aseprite/ph/amaranth-seed.aseprite", D .. "img-redraw-full/png/ph/amaranth-seed.png")
print(GV.report(t))
