local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local paper = c:rect(21, 8, 43, 32):cut(c:rect(40, 8, 43, 11)):add(c:poly({ {40, 8}, {44, 12}, {40, 12} }))
local box = c:rrect(9, 28, 55, 54, 3)
local lid = c:rrect(7, 27, 57, 33, 2)

local p = c:build{
  { "paper", paper, "#f8eed2", { gloss = { 24, 11 } } },
  { "box",   box,   "#a5663a" },
  { "lid",   lid,   "#b07a45", { gloss = { 11, 29 } } },
}
-- tick
c:fill(c:line({ {26, 18}, {30, 22}, {38, 13} }, 3), "#58a03e")
c:fill(c:line({ {26, 17}, {30, 21} }, 1), "#7ab55c")
-- slot bar on box front
c:fill(c:rrect(19, 38, 45, 43, 1), "#2a1a10")
c:fill(c:rect(20, 39, 44, 39), "#4a2c1a")

local t = c:save(D .. "img-redraw-full/aseprite/ico/ico-ballot.aseprite", D .. "img-redraw-full/png/ico/ico-ballot.png")
print(GV.report(t))
