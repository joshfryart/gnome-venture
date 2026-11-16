-- Lightning Pinch (pl-hcr-1), yard 64x64. Haiku first pass.
-- Thornblade, common. A little claw of lightning.
-- quirk: a sneeze puff with sparks at the top right.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "pl-hcr-1-yard" }
c:groundShadow(32, 59, 14, 3)
c:part(c:poly{ {4,30},{12,22},{10,28},{17,25},{14,37},{5,37} }, "sky", {})
c:part(c:poly{ {60,30},{52,22},{54,28},{47,25},{50,37},{59,37} }, "sky", {})
c:part(c:ellipse(32, 40, 15, 13), "gold", {})
c:eyeLocked(24, 35)
c:eyeLocked(35, 35)
c:paint({ ".ii.", "i..i", ".ii." }, 29, 44, { i = "#2b1c26" })
local puff = c:ellipse(50, 12, 8, 6)
puff:add(c:ellipse(58, 17, 4, 3))
c:part(puff, "sky", {})
c:sparkle(40, 8)
c:px(36, 3, "#ffe38a")
c:px(42, 20, "#ffe38a")
c:finish{ outline = true }
HP.assertClean(c)
local out = app.params.out or (dir .. "/")
c:save{ aseprite = out .. "pl-hcr-1-yard.aseprite", png = out .. "pl-hcr-1-yard.png" }
