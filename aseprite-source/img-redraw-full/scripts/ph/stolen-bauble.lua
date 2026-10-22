local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local gem = c:poly({ {32, 15}, {51, 31}, {32, 56}, {13, 31} })
local loop = c:ellipse(32, 9.5, 3, 2.5):cut(c:rect(31, 9, 32, 10))
local cap = c:rrect(26, 11, 37, 16, 2)

local p = c:build{
  { "loop", loop, "gold", { flat = true } },
  { "gem",  gem,  "moss", { gloss = false } },
  { "cap",  cap,  "gold", { gloss = false } },
}

-- lit upper-left facet
local lit = c:poly({ {32, 17}, {14, 31}, {25, 31} }):clip(p.gem.m)
c:fill(lit, "#a4b86a")
-- facet lines and girdle
local F = "#4a8a3e"
local fl = c:line({ {14, 30}, {50, 30} }, 2)
fl:add(c:line({ {31, 17}, {24, 30}, {31, 54} }, 2))
fl:add(c:line({ {32, 17}, {39, 30}, {32, 54} }, 2))
fl:clip(p.gem.m:shrink(2))
c:fill(fl, F)
c:gloss(p.gem.m, GV.R.moss, { 22, 26 })
c:button(30, 12)

local t = c:save(O .. "aseprite/ph/stolen-bauble.aseprite", O .. "png/ph/stolen-bauble.png")
print(GV.report(t))
