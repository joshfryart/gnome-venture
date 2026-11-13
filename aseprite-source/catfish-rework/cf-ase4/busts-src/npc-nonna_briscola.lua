-- Nonna Briscola: brown bear grandmother, red polka-dot headscarf, hugging a stitched felt sardine (quirk)
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(DIR .. "/../banners/bust.lua")
local HP, P = M.HP, M.P
local c = M.new("npc-nonna_briscola")
local R = M.R
local fur = R("#9a6238", { hi = "#c48a58", shade = "#6e4030", deep = "#3e2428" })
local muz = R("#e8c49a", { hi = "#fbe6c2", shade = "#b8845e", deep = "#6e4030" })
local red = R("#d8453f", { hi = "#ff8a6a", shade = "#a82a38", deep = "#6a1a2e" })
local olive = R("#8a9a46", { hi = "#c4d078", shade = "#5e7a42", deep = "#34503c" })
local dusk = R("#5a459e", { hi = "#8a6fd0", shade = "#3e3076", deep = "#241a4a" })
local fish = R("#6a9cc8", { hi = "#b4dcf0", shade = "#4a6ea8", deep = "#2e4478" })
-- body: dusk dress + olive shawl
local dress = c:ellipse(39.5, 104, 34, 28):clip(c:rect(0, 72, 79, 99))
M.part(c, dress, dusk, { band = 2 })
local shawl = c:poly({ { 8, 100 }, { 12, 82 }, { 24, 72 }, { 39, 80 }, { 55, 72 }, { 68, 82 }, { 72, 100 } })
M.part(c, shawl, olive, { band = 2, pop = { x = 16, y = 82 } })
for x = 12, 68, 4 do M.pts(c, { { x, 98, olive.deep }, { x + 1, 97, olive.shade } }) end -- knit rows
for y = 80, 96, 4 do shawl:copy():clip(c:rect(0, y, 79, y)):each(function(x, yy) if (x + yy) % 4 < 2 then M.keep(c, x, yy, olive.shade) end end) end
-- ears (under scarf)
for _, e in ipairs({ { 22, 38 }, { 57, 38 } }) do
  M.part(c, c:ellipse(e[1], e[2], 6, 6), fur, { band = 2, nopop = true })
  c:fillMask(c:ellipse(e[1] + (e[1] < 40 and 1 or -1), e[2] + 1, 3, 3), muz.shade)
end
-- head
local head = c:ellipse(39.5, 53, 20, 17)
M.part(c, head, fur, { band = 3 })
M.ticks(c, head:copy():clip(c:rect(0, 0, 79, 40)), fur.hi, 7, 1)
-- scarf: dome + side bands framing the face, knot under chin
local face = c:ellipse(39.5, 58, 15, 13)
local scarf = c:ellipse(39.5, 50, 23.5, 22):cut(face):clip(c:rect(0, 0, 79, 73))
M.part(c, scarf, red, { band = 2, pop = { x = 26, y = 34 } })
for _, p in ipairs({ { 30, 32 }, { 38, 30 }, { 46, 32 }, { 22, 38 }, { 34, 36 }, { 42, 36 }, { 55, 38 }, { 19, 46 }, { 58, 46 }, { 18, 54 }, { 61, 54 }, { 19, 62 }, { 60, 62 }, { 26, 42 }, { 52, 42 } }) do
  if scarf:has(p[1], p[2]) then M.keep(c, p[1], p[2], "#fff4d6") M.keep(c, p[1] + 1, p[2], "#fff4d6") end
end
M.pts(c, { { 25, 48 }, { 26, 46 }, { 27, 45 }, { 28, 44 }, { 52, 44 }, { 53, 45 }, { 54, 46 }, { 55, 48 } }, red.shade)
local knot = c:ellipse(39.5, 72, 8, 3)
M.part(c, knot, red, { band = 1, nopop = true })
M.pts(c, { { 36, 72 }, { 43, 72 } }, red.deep)
c:fillMask(c:poly({ { 33, 73 }, { 28, 79 }, { 33, 80 }, { 36, 75 } }), red.base) c:fillMask(c:poly({ { 46, 73 }, { 51, 79 }, { 46, 80 }, { 43, 75 } }), red.base)
-- muzzle + nose
M.part(c, c:ellipse(39.5, 60, 10, 7.5), muz, { band = 2, nopop = true })
M.noseBall(c, 37, 54, { base = "#5a3a38", hi = "#8a6860", shade = "#3a2428", deep = "#2b1c26" }, "#2b1c26")
M.pts(c, { { 38, 56 }, { 39, 56 } }, "#8a6860")
M.pts(c, { { 36, 62 }, { 37, 63 }, { 38, 63 }, { 39, 62 }, { 40, 62 }, { 41, 63 }, { 42, 63 }, { 43, 62 } }, muz.deep)
M.eyes(c, 30, 46, 44, 46)
M.pts(c, { { 29, 44 }, { 30, 43 }, { 31, 43 }, { 32, 43 }, { 45, 43 }, { 46, 43 }, { 47, 43 }, { 48, 44 } }, fur.deep)
c:cheek(26, 55) c:cheek(52, 55)
-- sardine, held across the chest
local body = c:ellipse(39.5, 88, 15, 5.5)
local tail = c:poly({ { 52, 88 }, { 60, 82 }, { 60, 94 } })
M.part(c, tail, fish, { band = 1, nopop = true })
M.part(c, body, fish, { band = 2, pop = { x = 30, y = 85 } })
for x = 31, 50, 3 do M.pts(c, { { x, 86, fish.shade }, { x + 1, 87, fish.shade }, { x, 88, fish.shade }, { x + 1, 89, fish.shade } }) end
M.pts(c, { { 28, 87, "#2b1c26" }, { 29, 87, "#fff4d6" } })
c:fillMask(c:rect(33, 91, 46, 91), fish.hi)
M.pts(c, { { 25, 90, fish.deep }, { 26, 91, fish.deep } })
c:stitch({ { 31, 83 }, { 48, 83 } })
-- paws
M.part(c, c:ellipse(24, 91, 5, 4), fur, { band = 1, nopop = true }) M.part(c, c:ellipse(56, 91, 5, 4), fur, { band = 1, nopop = true })
M.fin(c, "npc-nonna_briscola", { base = "#b4dcf0", shade = "#8cbce4", deep = "#6a9cd0" })
