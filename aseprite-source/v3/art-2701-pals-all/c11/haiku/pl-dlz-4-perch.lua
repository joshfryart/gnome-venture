-- Diamond Spur (pl-dlz-4), perch 36x36. Haiku first pass (c11/haiku), hand-drawn at this size.
-- Wood-brown body, three gold diamonds on the back, hooked tail.
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../../../lib/hp.lua")
local out = app.params.out or "./"
local INK = "#2b1c26"
local c = HP.canvas{ w = 36, h = 36, scale = 4, name = "pl-dlz-4-perch" }

local function dia(cx, cy) return c:poly{ { cx, cy - 2 }, { cx + 2, cy }, { cx, cy + 2 }, { cx - 2, cy } } end

c:groundShadow(18, 33, 11, 1)
c:part(c:line({ { 26, 27 }, { 31, 27 }, { 32, 24 } }, 2), "wood", { band = 1 })
c:part(c:rect(12, 30, 13, 31), "wood", { band = 1 })
c:part(c:rect(22, 30, 23, 31), "wood", { band = 1 })
c:part(c:ellipse(18, 24, 10, 7), "wood")
c:part(dia(11, 21), "gold", { noshade = true, nopop = true })
c:part(dia(18, 19), "gold", { noshade = true, nopop = true })
c:part(dia(25, 21), "gold", { noshade = true, nopop = true })
c:eyeSmall(13, 25) c:eyeSmall(21, 25)
c:px(16, 28, INK) c:px(17, 28, INK) c:px(18, 28, INK)
c:sparkle(28, 14)

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "pl-dlz-4-perch.aseprite", png = out .. "pl-dlz-4-perch.png", scale = 1 }
