local G = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gnome-parts/scripts/gnome-common.lua")
local GV = G.GV
local c = G.canvas()
-- ears, round face, nose, locked v06 eyes, 1 px brim contact shadow
c:part(G.ears(c), G.R.skin, { cres = 2, deep = 0, gloss = false })
local face = G.face(c)
c:part(face, G.R.skin, { gloss = { 28, 46 } })
c:part(G.nose(c), G.R.nose, { cres = 2, deep = 0, gloss = { 38, 51 } })
c:px(23, 46, G.R.skin.shade); c:px(23, 47, G.R.skin.shade); c:px(57, 46, G.R.skin.shade); c:px(57, 47, G.R.skin.shade)
for x = 24, 56 do if face:has(x, 44) and face:has(x, 43) then c:px(x, 44, G.R.skin.shade) end end
c:eye(32, 45); c:eye(44, 45)
G.save(c, "gnome-face")
