-- Howl Echo (pl-gwk-5), yard 64x64. Haiku first pass.
-- Rootwarden, uncommon. A rounded sea-blue howl with its rings echoing off the top right.
-- quirk: two echo rings, each a little smaller than the last.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "pl-gwk-5-yard" }
local r1 = c:ellipse(32, 36, 29, 29); r1:cut(c:ellipse(32, 36, 27, 27)); r1:clip(c:rect(38, 0, 63, 30))
c:part(r1, "sea", { noshade = true })
local r2 = c:ellipse(32, 36, 22, 22); r2:cut(c:ellipse(32, 36, 20, 20)); r2:clip(c:rect(38, 0, 63, 30))
c:part(r2, "sky", { noshade = true })
c:part(c:rrect(16, 22, 48, 54, 14), "sea", {})
c:eyeLocked(24, 30)
c:eyeLocked(35, 30)
c:part(c:ellipse(32, 44, 4, 4), "dusk", { noshade = true })
c:finish{ outline = true }
HP.assertClean(c)
local out = app.params.out or (dir .. "/")
c:save{ aseprite = out .. "pl-gwk-5-yard.aseprite", png = out .. "pl-gwk-5-yard.png" }
