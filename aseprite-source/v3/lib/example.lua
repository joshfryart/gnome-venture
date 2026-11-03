-- Demo: 64x64 acorn. Run: AppRun -b --script-param out=<dir>/ --script example.lua
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../lib/hp.lua")
local out = app.params.out or "./"
local c = HP.canvas{ w = 64, h = 64, scale = 4, name = "acorn" }
c:groundShadow(32, 56, 14, 2)
c:part(c:ellipse(32, 36, 14, 16), "gold")                                   -- nut
c:part(c:rrect(18, 14, 46, 28, 6):clip(c:rect(0, 0, 63, 28)), "wood")       -- cap (inner line vs nut)
c:part(c:rect(30, 7, 33, 14), "wood", { band = 1 })                         -- stem
c:part(c:poly({ {34,9},{43,5},{44,10},{37,12} }), "moss", { band = 1 })     -- quirk: leaf on the stem
c:eyeSmall(25, 34) c:eyeSmall(37, 34) c:cheek(22, 40) c:cheek(40, 40)
c:stitch({ {19, 25}, {44, 25} })
c:sparkle(23, 20)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "acorn.aseprite", png = out .. "acorn.png", scale = 1 }
c:save{ png = out .. "acorn_x4.png", scale = 4 }
