local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../lib/hp.lua")
local out = app.params.out or "./"
local c = HP.canvas{ w = 64, h = 64, scale = 4, name = "acai" }
c:groundShadow(32, 57, 15, 2)
c:part(c:ellipse(32, 23, 5, 5), "dusk")                -- quirk: shy small berry tucked behind
c:part(c:ellipse(22, 29, 7, 7), "dusk")
c:part(c:ellipse(42, 29, 7, 7), "dusk")
c:part(c:rect(31, 8, 33, 24), "moss", { band = 1, nopop = true })
c:part(c:poly{ {33,12},{44,7},{47,12},{38,16} }, "moss", { band = 1 })
c:part(c:poly{ {31,14},{20,10},{17,15},{26,18} }, "moss", { band = 1 })
c:part(c:ellipse(32, 33, 7, 7), "dusk")
c:part(c:ellipse(24, 40, 7, 7), "dusk")
c:part(c:ellipse(40, 40, 7, 7), "dusk")
c:part(c:ellipse(32, 48, 7, 7), "dusk")
c:sparkle(27, 28)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "acai.aseprite", png = out .. "acai.png", scale = 1 }
