local G = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gnome-parts/scripts/gnome-common.lua")
local GV = G.GV
local c = G.canvas()
-- tier III gold star on the hat cone
c:part(G.star(c), G.R.gold, { cres = 3, deep = 0, gloss = { 38, 21 } })
G.save(c, "gnome-star")
