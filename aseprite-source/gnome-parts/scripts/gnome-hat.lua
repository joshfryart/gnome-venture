local G = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gnome-parts/scripts/gnome-common.lua")
local GV = G.GV
local c = G.canvas()
-- TINTABLE (multiply): pointed felt hat, neutral greys only, light-thread edge stitch + brim seam
G.neutral(true)
c:part(G.cone(c), G.N.hat, { gloss = { 32, 26 }, stitch = { side = "lit" } })
c:part(G.brim(c), G.N.brim, { cres = 2, deep = 0, gloss = false })
c:seam({ { 21, 40 }, { 59, 40 } })
G.save(c, "gnome-hat")
