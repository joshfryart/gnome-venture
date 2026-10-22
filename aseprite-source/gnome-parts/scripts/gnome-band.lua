local G = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gnome-parts/scripts/gnome-common.lua")
local GV = G.GV
local c = G.canvas()
-- tier II gold hat band over the top half of the brim, with light thread dashes
local band = G.band(c)
c:part(band, G.R.gold, { cres = 2, deep = 0, gloss = false, contact = false })
for x = 23, 57 do if x % 3 ~= 2 and band:has(x, 38) then c:px(x, 38, "#fff1c8") end end
G.save(c, "gnome-band")
