-- Grey Wolf Whistle (pl-gwk-6), yard 64x64. Haiku first pass.
-- Wayfinder, rare. A silver wolf-head whistle with gold trim.
-- quirk: small sky-blue sound ticks at the snout, and a gold collar seam.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "pl-gwk-6-yard" }
c:part(c:poly{ {17,30}, {15,6}, {31,22} }, "stone", { sep = true })
c:part(c:poly{ {47,30}, {49,6}, {33,22} }, "stone", { sep = true })
c:part(c:poly{ {14,9}, {15,6}, {18,11} }, "gold", {})
c:part(c:poly{ {50,9}, {49,6}, {46,11} }, "gold", {})
c:part(c:ellipse(32, 36, 18, 14), "stone", {})
c:part(c:rrect(28, 40, 52, 50, 4), "stone", { sep = true })
c:part(c:rect(38, 40, 39, 50), "gold", {})
c:part(c:ellipse(50, 45, 2, 2), "dusk", {})
c:eyeLocked(20, 32)
c:eyeLocked(37, 32)
c:part(c:rect(58, 36, 59, 36), "sky", { noshade = true })
c:part(c:rect(58, 42, 59, 42), "sky", { noshade = true })
c:finish{ outline = true }
HP.assertClean(c)
local out = app.params.out or (dir .. "/")
c:save{ aseprite = out .. "pl-gwk-6-yard.aseprite", png = out .. "pl-gwk-6-yard.png" }
