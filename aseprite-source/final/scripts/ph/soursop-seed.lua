local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local tab = c:poly({ {44, 6}, {54, 20}, {38, 20} })
local body = c:rrect(14, 18, 50, 56, 3)
local flap = c:poly({ {14, 18}, {51, 18}, {51, 28}, {32, 32}, {14, 28} }):clip(body)
local seed = c:ellipse(32, 44, 10, 10)
local stem = c:rect(31, 30, 33, 35)
local leaf = c:ellipse(38.5, 30, 4.5, 2.5)

c:build{
  { "tab",  tab,  "#4a8a3e", { gloss = false } },
  { "body", body, "#f1ece0", { light = body } },
  { "flap", flap, "#dcb06a", { light = body, gloss = false } },
  { "seed", seed, "#3f93b2" },
  { "stem", stem, "#2e5a2c", { flat = true } },
  { "leaf", leaf, "#58a03e", { flat = true } },
}
-- fold crease on the flap
c:fill(c:rect(20, 23, 44, 24), "#a5663a")
-- thread stitch down the left of the packet
c:seam({ {18, 34}, {18, 52} })
c:button(30, 26)

local t = c:save(O .. "aseprite/ph/soursop-seed.aseprite", O .. "png/ph/soursop-seed.png")
print(GV.report(t))
