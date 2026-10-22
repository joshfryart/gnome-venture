local G = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gnome-parts/scripts/gnome-common.lua")
local GV = G.GV
local c = G.canvas()
-- tunic (moss) + belt (bark), felt edge stitch, hem seam, 4x4 gold button on the belt
local tun = G.tunic(c)
c:part(tun, G.R.tunic, { gloss = false, stitch = { side = "lit" } })
c:seam({ { 19, 89 }, { 61, 89 } })                       -- hem
c:part(G.belt(c, tun), G.R.belt, { cres = 2, deep = 0, gloss = false })
c:button(25, 78)
G.save(c, "gnome-body")
