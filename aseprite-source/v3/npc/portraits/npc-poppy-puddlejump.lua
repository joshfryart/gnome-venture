-- npc-poppy-puddlejump portrait (npc2 P1_30) species: hare-eared rabbit
-- 80x100 head+shoulders: tan rabbit, one tall ear + one flopped tip, buck teeth, orange jumper, green scarf; poppy wreath in frame.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-poppy-puddlejump"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
local FUR = { hi = "#f6d6a0", base = "#dca86c", shade = "#b0743f", deep = "#6a3e2e" }
local JMP = { hi = "#ffb47a", base = "#f0823e", shade = "#c4513a", deep = "#6e2038" }
local CR = { hi = P.cream, base = "#f3e2bf", shade = "#d9b99a", deep = "#9a6f63" }
local jm = c:ellipse(39.5, 108, 32, 33):clip(c:rect(0, 74, 79, 99))
c:part(jm, JMP, { band = 3 })
for x = 10, 70, 3 do c:fillMask(c:line({ {x,92},{x,99} }, 1):clip(jm), JMP.shade) end
c:part(c:rrect(21, 68, 58, 77, 4), "moss", { band = 2 })
for _, x in ipairs{ 28, 35, 42, 49 } do c:fillMask(c:line({ {x,69},{x+2,76} }, 1), P.moss.shade) end
c:part(c:line({ {49,75},{51,86},{53,96} }, 6), "moss", { band = 2, nopop = true })
for _, x in ipairs{ 50, 52, 54 } do c:put(x, 98, P.moss.deep) c:put(x, 99, P.moss.deep) end
c:fillMask(c:line({ {48,88},{55,88} }, 1):clip(c:line({ {49,75},{51,86},{53,96} }, 6)), P.moss.deep)
-- ears
local le = c:ellipse(31, 21, 5.5, 16)
c:part(le, FUR, { band = 2 })
c:part(c:ellipse(31, 23, 2, 12), "petal", { band = 1, nopop = true })
local re = c:ellipse(48, 28, 5.5, 10)
re:add(c:line({ {48,20},{54,16},{60,18},{63,22} }, 6))
c:part(re, FUR, { band = 2 })
c:part(c:ellipse(48, 30, 2, 6), "petal", { band = 1, nopop = true })
c:fillMask(c:line({ {50,19},{55,18} }, 1), FUR.shade)
-- head
local h = c:ellipse(39.5, 53, 19, 16)
for _, q in ipairs{ {20,58},{21,62},{58,58},{57,62} } do h:add(c:ellipse(q[1], q[2], 2, 2)) end
c:part(h, FUR, { band = 3, pop = { x = 27, y = 42 } })
-- wreath + poppy
c:part(c:line({ {21,48},{26,42},{33,38},{40,37},{47,38},{53,42},{58,48} }, 3), "moss", { band = 1, inner = false, nopop = true })
for _, q in ipairs{ {24,44},{30,40},{37,38},{44,38} } do c:put(q[1], q[2], P.moss.hi) c:put(q[1] + 1, q[2], P.moss.hi) end
local pop = c:ellipse(52, 40, 4, 4)
for _, q in ipairs{ {52,35},{57,40},{52,45},{47,40} } do pop:add(c:ellipse(q[1], q[2], 1.5, 1.5)) end
c:part(pop, "ember", { band = 2, pop = { x = 49, y = 37 } })
c:fillMask(c:rect(51, 39, 52, 40), P.ink) c:put(51, 39, P.ember.deep)
-- face
c:part(c:ellipse(39.5, 61, 8, 5.5), CR, { band = 2 })
c:paint({ "hPPP", ".PP." }, 38, 56, { P = "petal.base", h = "petal.hi" })
c:paint({ "...ii...", ".ii..ii.", "..iCCi..", "..iCCi..", "...ii..." }, 36, 58, { i = "ink", C = "cream" })
c:eyeLocked(29, 48) c:eyeLocked(46, 48)
c:cheek(25, 57) c:cheek(53, 57)
c:finish{ outline = true }
backdrop(P.sea)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
