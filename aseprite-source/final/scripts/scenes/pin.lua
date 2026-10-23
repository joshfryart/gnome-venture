-- map/pin : 16x16 gold stitched button, 1 px black border (sprite)
local H = dofile(os.getenv("GV_ROOT") .. "aseprite-source/final/scripts/scenes/head.lua")
local GV = H.GV
local c = GV.canvas{ w = 16, h = 16, mode = "icon", margin = 1 }
local disc = c:ellipse(7.5, 7.5, 5.5, 5.5)
c:part(disc, "gold", { ol = 1, olx = 0, gloss = false, cres = 2, deep = 1 })
-- inner stitch ring (thread gold, dashed) and two thread holes
c:stitch(disc)
c:px(6, 6, GV.C.hole); c:px(9, 9, GV.C.hole)
c:px(4, 4, "#fff1c8"); c:px(5, 4, "#fff1c8")
H.done(c, "pin", "map/pin.png", 16)
