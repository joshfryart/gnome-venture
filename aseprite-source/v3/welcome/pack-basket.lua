-- pack-basket FIRST DRAFT. 32x32 icon: small woven basket with fruit. quirk: one apple wears a green leaf.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or (d .. "/")
local NAME = "pack-basket"
local c = HP.canvas{ w = 32, h = 32, scale = 1, name = NAME }
c:groundShadow(16, 30, 12, 1)
-- fruit behind rim
c:part(c:ellipse(9.5, 13.5, 4.5, 4.5), "ember", { band = 2, pop = { x = 7, y = 11 } })
c:part(c:ellipse(22.5, 13.5, 4.5, 4.5), "gold", { band = 2, pop = { x = 20, y = 11 } })
c:part(c:ellipse(16, 11, 5, 5), "ember", { band = 2, pop = { x = 13, y = 8 } })
c:part(c:poly{ {17,6},{21,2},{24,4},{20,7} }, "moss", { band = 1, nopop = true })
-- handle arc (thin, behind fruit would hide; draw as two side posts)
c:part(c:rect(5, 14, 6, 19), "wood", { band = 1, nopop = true, inner = false })
c:part(c:rect(25, 14, 26, 19), "wood", { band = 1, nopop = true, inner = false })
-- basket body (tapered) + rim band
local body = c:poly{ {3,18},{28,18},{25,29},{6,29} }
c:part(body, "wood", { band = 3, pop = { x = 6, y = 21 } })
for y = 21, 28, 3 do c:fillMask(c:rect(4, y, 27, y):clip(body), P.wood.shade) end
for x = 7, 25, 4 do c:fillMask(c:line({ {x, 19}, {x - 1, 28} }, 1):clip(body), P.wood.deep) end
c:part(c:rect(2, 16, 29, 19), "wood", { band = 1, nopop = true })
c:fillMask(c:rect(3, 16, 28, 16), P.wood.hi)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
