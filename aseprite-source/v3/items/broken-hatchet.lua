local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../lib/hp.lua")
local out = app.params.out or "./"
local c = HP.canvas{ w = 64, h = 64, scale = 4, name = "broken-hatchet" }
c:groundShadow(32, 60, 10, 2)
c:part(c:poly{ {28,36},{30,33},{31,36},{33,32},{34,35},{34,57},{28,57} }, "wood")      -- lower handle
c:part(c:poly{ {28,8},{34,8},{34,27},{33,30},{31,26},{30,30},{28,27} }, "wood")        -- upper stub
local head = c:poly{ {28,11},{18,8},{11,14},{14,19},{11,24},{18,30},{28,27} }
head:add(c:rect(28,11,38,26))
c:part(head, "stone")
for _, p in ipairs{ {31,30},{30,32},{31,34},{30,36} } do c:px(p[1], p[2], "#2b1c26") end -- crack
c:part(c:poly{ {42,31},{46,28},{48,32},{44,35} }, "wood", { band = 1 })                  -- flying chip
c:px(40, 36, "#2b1c26") c:px(50, 30, "#fff4d6")
for _, y in ipairs{ 42, 44, 46 } do c:fillMask(c:rect(28, y, 34, y), "#f5b82e") end      -- quirk: unravelling thread
c:fillMask(c:rect(35,46,36,46), "#f5b82e") c:fillMask(c:rect(36,47,37,48), "#f5b82e")
c:fillMask(c:rect(37,49,38,49), "#d98322")
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "broken-hatchet.aseprite", png = out .. "broken-hatchet.png", scale = 1 }
