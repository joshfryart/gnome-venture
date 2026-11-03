local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../lib/hp.lua")
local out = app.params.out or "./"
local P = HP.P or dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../lib/palette.lua")

local NAME = "npc-bramble-mossfoot"
local c = HP.canvas{ w = 80, h = 100, scale = 4, name = NAME }
local disc = c:ellipse(39.5, 44.5, 31, 31)
c:fillMask(disc, P.sea.base)
c:fillMask(disc:copy():cut(disc:copy():shift(-2, -2)), P.sea.shade)
-- spiky crown: one mask of triangles around the head
local sp = c:ellipse(40, 46, 22, 20)
local cx, cy = 40, 46
for i = 0, 16 do
  local a = math.rad(165 + i * 12.5)
  local len = 31 + ((i % 3) == 1 and 3 or 0)
  local tx, ty = cx + math.cos(a) * len, cy + math.sin(a) * (len * 0.92)
  local b1, b2 = a - 0.2, a + 0.2
  sp:add(c:poly{ {math.floor(cx+math.cos(b1)*18+.5), math.floor(cy+math.sin(b1)*17+.5)},
                 {math.floor(tx+.5), math.floor(ty+.5)},
                 {math.floor(cx+math.cos(b2)*18+.5), math.floor(cy+math.sin(b2)*17+.5)} })
end
c:part(sp, "wood", { band = 3 })
-- jumper (bleeds off bottom)
c:part(c:poly{ {6,99},{10,84},{24,72},{40,76},{56,72},{70,84},{74,99} }, "moss")
c:part(c:rect(33, 64, 47, 74), "skinA")
-- face
c:part(c:ellipse(40, 50, 19, 17), "skinA")
c:eyeLocked(30, 44) c:eyeLocked(43, 44)
c:cheek(27, 54) c:cheek(50, 54)
c:fillMask(c:rect(38, 53, 43, 55), P.ink) c:px(37, 58, P.skinA.deep) c:px(38, 59, P.skinA.deep) c:px(39, 59, P.skinA.deep) c:px(40, 59, P.skinA.deep) c:px(41, 59, P.skinA.deep) c:px(42, 58, P.skinA.deep)

-- scarf
c:part(c:poly{ {26,70},{40,76},{54,70},{56,76},{40,82},{24,76} }, "ember")
c:part(c:rect(46, 76, 52, 92), "ember", { band = 2 })
-- button
c:button(33, 90)
-- leaf behind left ear (quirk)
c:part(c:poly{ {14,44},{22,36},{25,43},{19,49} }, "moss", { band = 1 })
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
c:save{ png = "/tmp/claude-0/-home-user-gnome-venture/24dbc14e-ae34-540a-ac1a-cc6317049307/scratchpad/" .. NAME .. "_x4.png", scale = 4 }
