-- Bill Brolly (mt-bill-brolly), perch sprite 36x36, hand-built at this size (opus3 richness pass, from opus2).
-- opus3: frog eyes are now 2x2 ink with a cream glint on bigger bulges (opus2's were 1x2 px), wider frog grin and a
-- spot; feather scallops, cream primary tips, bill serrations, rain beads on the leaf, brass compass at the neck.
-- Charcoal hornbill with cream belly, big gold bill and ember casque (the read at this size), holding an arched
-- leaf brolly on a stalk that reaches out over a little frog. Pill eyes with a lash each.
-- quirk: the frog under the leaf edge (2 bulging pill eyes, a grin).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("mt-bill-brolly-perch", 36)

local CHAR = { "#2e2434", "#3e3248", "#54465e", "#6c5e78", "#8a7c96", "#a89cb2" }
local CRM  = { "#d8ccb0", "#efe6cc", "#fff4dc" }
local BEAK = { "#8f4a1f", "#d98322", "#f5b82e", "#ffd45e", "#ffe9a0" }
local CASQ = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
local LEAF = { "#1f4a3a", "#2a6440", "#3f8a48", "#5eaa52", "#8ccc64", "#bce488" }
local FROG = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }

c:groundShadow(15, 33, 8, 1.2)
local tl, tn = O.tube({ { 12, 25 }, { 9, 28 }, { 7, 30 }, { 5, 32 } }, function(t) return 1.8 - t * .6 end)
O.shadeN(c, tl, tn, CHAR, { amb = .3, sep = CHAR[1] })
O.dots(c, { { 6, 30 }, { 7, 30 }, { 6, 31 } }, CRM[2])
O.flat(c, c:rect(13, 30, 13, 32), "#74758c", "leg") O.flat(c, c:rect(17, 30, 17, 32), "#74758c", "leg")
local stalk, sn = O.tube({ { 20, 23 }, { 20, 18 }, { 19, 13 }, { 19, 8 } }, function() return .7 end)
O.shadeN(c, stalk, sn, LEAF, { amb = .3, sep = LEAF[1] })
local body = c:ellipse(15, 24, 6, 7)
local bI, bT = O.shade(c, body, CHAR, { sphere = { 12, 20, 10 }, amb = .3, wrap = .45, sep = CHAR[1], rim = true, bounce = "#5a6a9a", bmax = 2 })
O.tex(c, bI, bT, CHAR, function(x, y, i) if y % 3 == 2 and (x + (y // 3)) % 3 ~= 0 and i >= 3 then return -1 end end)
local bel = c:ellipse(16, 27, 3.5, 3.5) bel:clip(body)
O.shade(c, bel, CRM, { R = 2, amb = .4, cuts = { .35, .7 } })
O.shade(c, c:poly{ { 17, 20 }, { 21, 22 }, { 20, 25 }, { 17, 25 } }, CHAR, { R = 1, amb = .3, sep = CHAR[1], rim = true })
O.dots(c, { { 19, 25 }, { 20, 24 } }, CRM[2]) -- primary tips
O.dot(c, 15, 20, "#f5b82e") O.dot(c, 14, 20, "#8f4a1f") -- compass
local head = c:ellipse(15.5, 15, 5, 4.5)
O.shade(c, head, CHAR, { sphere = { 13, 12, 8 }, amb = .32, sep = CHAR[1], rim = true })
local beak = c:poly{ { 19, 14 }, { 25, 13 }, { 29, 15 }, { 31, 18 }, { 20, 17 } }
O.shade(c, beak, BEAK, { R = 1, amb = .32, sep = BEAK[1] })
O.dots(c, { { 21, 16 }, { 22, 16 }, { 23, 16 }, { 24, 16 }, { 26, 17 } }, BEAK[1]) O.dots(c, { { 22, 14 }, { 23, 14 } }, BEAK[5])
O.shade(c, c:poly{ { 19, 12 }, { 21, 10 }, { 26, 10 }, { 27, 12 }, { 20, 13 } }, CASQ, { R = 1, amb = .32, cuts = { .3, .55, .8 }, sep = CASQ[1] })
O.flat(c, c:rect(11, 12, 14, 16), CHAR[6], "facepatch") O.flat(c, c:rect(15, 12, 18, 16), CHAR[6], "facepatch")
O.dots(c, { { 11, 12 }, { 14, 12 }, { 11, 16 }, { 14, 16 }, { 15, 12 }, { 18, 12 }, { 15, 16 }, { 18, 16 } }, CHAR[4])
c:eyeSmall(12, 13)
c:eyeSmall(16, 13)
O.dot(c, 12, 11, "#2b1c26") O.dot(c, 17, 11, "#2b1c26")
O.dot(c, 10, 17, "#f5809f")
local leaf = HP.mask()
for x = 3, 33 do
  local t = (x - 3) / 30
  local top = 8 - math.sin(t * math.pi) * 5 + t * 2
  for y = math.floor(top), math.floor(top + 2 + math.sin(t * math.pi) * 2) do leaf:set(x, y) end
end
local lb = {}
leaf:each(function(x, y) local t = (x - 3) / 30 if y == math.floor(8 - math.sin(t * math.pi) * 5 + t * 2 + 1 + math.sin(t * math.pi)) then lb[K(x, y)] = 2 end end)
O.shade(c, leaf, LEAF, { R = 1, amb = .3, wrap = .45, bias = lb, sep = LEAF[1], rim = true })
for _, b in ipairs({ { 9, 5 }, { 25, 4 } }) do if leaf:has(b[1], b[2]) then O.dot(c, b[1], b[2], "#e4f6ff") end end
local fr = c:ellipse(28, 31.5, 4, 2) fr:add(c:ellipse(25.5, 28.5, 2, 2)) fr:add(c:ellipse(30.5, 28.5, 2, 2))
O.shade(c, fr, FROG, { R = 1, amb = .35, cuts = { .3, .55, .8 }, sep = FROG[1], rim = true })
-- bulging eyes: 2x2 ink, cream glint top-left
O.flat(c, c:rect(25, 28, 26, 29), "#2b1c26", "feye") O.dot(c, 25, 28, "#fff4d6")
O.flat(c, c:rect(30, 28, 31, 29), "#2b1c26", "feye") O.dot(c, 30, 28, "#fff4d6")
O.dots(c, { { 26, 31 }, { 27, 32 }, { 28, 32 }, { 29, 32 }, { 30, 31 } }, FROG[1]) -- grin
O.dot(c, 31, 32, FROG[1]) -- spot
O.done(c, "mt-bill-brolly-perch")
