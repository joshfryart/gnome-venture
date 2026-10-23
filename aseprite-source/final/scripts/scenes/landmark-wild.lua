-- map/landmark-wild : 16x16 red skull flag on a stone, 1 px black border (sprite)
local H = dofile(os.getenv("GV_ROOT") .. "aseprite-source/final/scripts/scenes/head.lua")
local GV = H.GV
local c = GV.canvas{ w = 16, h = 16, mode = "icon", margin = 1, ol = 1, olx = 0, cres = 2, deep = 1 }
local o = { gloss = false, flat = true }
c:part(c:ellipse(7.5, 12.5, 5, 1.5), "stone", { gloss = false, cres = 1, deep = 1 })   -- cairn stone
c:part(c:rect(3, 2, 4, 12), "wood", o)                                                 -- pole
local flag = c:rect(5, 2, 12, 8); flag:cut(c:rect(11, 8, 12, 8)); flag:cut(c:rect(8, 8, 8, 8))
c:part(flag, GV.ramp("#d6322b"), { gloss = false, flat = true })
-- skull: 5x4 cream, dark eye holes and tooth gaps
c:paint({ ".ccc.", "cucuc", ".ccc.", ".c.c." }, 7, 3, { c = "#f2e4c0", u = "#2a1a10" })
H.done(c, "landmark-wild", "map/landmark-wild.png", 16)
