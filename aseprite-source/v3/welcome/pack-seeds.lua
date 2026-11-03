-- pack-seeds FIRST DRAFT. 32x32 icon: seed packet with a sprout. quirk: the sprout wears one tiny cream seed-cap.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or (d .. "/")
local NAME = "pack-seeds"
local c = HP.canvas{ w = 32, h = 32, scale = 1, name = NAME }
c:groundShadow(16, 30, 10, 1)
-- sprout
c:part(c:rect(15, 6, 16, 11), "moss", { band = 1, nopop = true })
c:part(c:poly{ {14,7},{7,3},{4,6},{9,9},{14,9} }, "moss", { band = 1, pop = { x = 7, y = 5 } })
c:part(c:poly{ {17,6},{22,1},{28,2},{27,7},{20,9} }, "moss", { band = 1, pop = { x = 22, y = 3 } })
-- packet body + folded top flap
local body = c:rect(6, 11, 25, 29)
c:part(body, "ember", { band = 3, pop = { x = 8, y = 14 } })
c:part(c:rect(6, 10, 25, 14), "ember", { band = 1, nopop = true })
c:fillMask(c:rect(7, 12, 24, 12), P.ember.hi)
for x = 7, 24, 2 do c:px(x, 11, P.ember.deep) end
-- label
local lab = c:ellipse(15.5, 21.5, 7, 6)
c:part(lab, { hi = P.cream, base = P.cream, shade = "#f0dcb0", deep = P.gold.shade }, { band = 1, nopop = true })
-- seed on label
c:part(c:ellipse(15.5, 21.5, 2.5, 3.5), "gold", { band = 1, nopop = true })
c:px(15, 20, P.gold.hi)
c:sparkle(5, 14)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
