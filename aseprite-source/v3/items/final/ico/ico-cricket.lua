local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA3.lua")
local HP, X = D.HP, D.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local INK, CR = D.INK, D.CR
-- ico-cricket: green-brown cricket in side view, folded hind leg, long curved antennae.
-- quirk: it has a tiny gold music note floating over it, chirping.
local c = D.new("ico-cricket")
local L = { hi = "#b0d060", base = "#5f9a3c", shade = "#3a6a34", deep = "#1f4030" }
-- antennae
c:part(c:line({ { 46, 28 }, { 54, 18 }, { 60, 20 } }, 2), L, { noshade = true, nopop = true })
c:part(c:line({ { 44, 26 }, { 48, 14 }, { 56, 10 } }, 2), L, { noshade = true, nopop = true })
-- hind leg (big folded)
c:part(c:line({ { 20, 38 }, { 12, 24 }, { 22, 44 } }, 4), L, { noshade = true, nopop = true })
c:part(c:line({ { 22, 44 }, { 12, 56 } }, 3), L, { noshade = true, nopop = true })
-- other legs
c:part(c:line({ { 32, 44 }, { 30, 56 } }, 3), L, { noshade = true, nopop = true })
c:part(c:line({ { 40, 44 }, { 46, 56 } }, 3), L, { noshade = true, nopop = true })
-- body
local ab = D.ell(26, 38, 16, 8, 0.25)
D.lit(ab, "moss", 6, { })
D.lit(D.ell(23, 36, 13, 4.5, 0.25), { "#3a2a1c", "#5a3c24", "#7a5230", "#a07040", "#c49058", "#e0b078" }, 3)
local th = D.ell(40, 37, 6, 7)
D.lit(th, "moss", 4)
D.seam(c, ab, th, "#1f4030")
local hd = D.ell(46, 32, 6, 6)
D.lit(hd, "moss", 4)
D.fill(c:rect(46, 30, 47, 32), D.INK) D.px(46, 30, D.CR)
D.fill(c:rect(49, 35, 51, 36), "#1f4030")
-- note
D.fill(c:rect(12, 10, 14, 12), D.GOLD[4]) D.fill(c:rect(14, 3, 15, 11), D.GOLD[4]) D.fill(c:rect(15, 3, 19, 5), D.GOLD[4])
D.fin()
