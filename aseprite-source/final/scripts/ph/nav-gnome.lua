local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local T = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local face  = c:ellipse(32, 39, 10.5, 9.5)
local hat   = c:poly({ {19, 31}, {37, 8}, {46, 31} })
local band  = c:rrect(18, 27, 46, 33, 2)
local pom   = c:ellipse(37.5, 9, 3, 3)
local beard = c:ellipse(32, 46, 13, 6):cut(c:rect(0, 0, 63, 45))
beard:add(c:poly({ {19, 46}, {46, 46}, {33, 57}, {32, 57} }))
beard:add(c:ellipse(27.5, 43, 5, 2.5)):add(c:ellipse(36.5, 43, 5, 2.5))
local nose  = c:ellipse(32, 40.5, 2.5, 2)

c:build{
  { "face",  face,  "skin" },
  { "hat",   hat,   GV.ramp("#d6322b") },
  { "band",  band,  GV.ramp("#c66b50"), { gloss = false } },
  { "pom",   pom,   "cream", { gloss = false } },
  { "beard", beard, "cream" },
  { "nose",  nose,  "petal", { gloss = false, contact = false } },
}
c:seam({ {20, 30}, {44, 30} })
c:eye(25, 35, true); c:eye(36, 35, true)

local t = c:save(T .. "aseprite/ph/nav-gnome.aseprite", T .. "png/ph/nav-gnome.png")
print(GV.report(t))
