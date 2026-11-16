-- Buttress Tangle (pl-sbs-3), perch sprite 36x36. Opus second pass (c12/opus2), hand-built at this size.
-- Two flared buttress roots meeting in an arch over a dark hollow; a big cream ball of wound silk (crossing
-- strand grooves) sits in the mouth with two thread arms out to the roots. Face: 2x3 pills with steady brows,
-- cheeks, firm smile.
-- quirk: an acorn from the hidden stash peeks out of the dark behind it.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-sbs-3-perch", 36)

local BARK = { "#2e1c22", "#4a2c2a", "#6e4232", "#965f40", "#bb8456", "#d8a874" }
local MOSS = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local SILK = { "#5a4440", "#8a6e5e", "#b8a08a", "#dccab0", "#f0e4cc", "#fbf5e6" }
local NUT  = { "#3a2420", "#5e3a26", "#8a5a30", "#b98040", "#dca85a", "#f0cc84" }
local CAP  = { "#3a2a24", "#5a4030", "#7e5c40", "#a07a56", "#c49c72", "#e0c094" }

c:groundShadow(18, 32, 15, 1)
local hollow = c:ellipse(18, 21, 9, 13) hollow:cut(c:rect(0, 32, 35, 35))
O.flat(c, hollow, "#2a1a24", "hollow")
local lm, ln = O.tube({ { 17, 5 }, { 10, 8 }, { 6, 18 }, { 6, 31 } }, function(t) return 2 + 1.2 * t end)
local rm, rn = O.tube({ { 19, 5 }, { 26, 8 }, { 30, 18 }, { 30, 31 } }, function(t) return 2 + 1.2 * t end)
lm:cut(c:rect(0, 32, 35, 35)) rm:cut(c:rect(0, 32, 35, 35))
local lI, lT = O.shadeN(c, lm, ln, BARK, { amb = .22, wrap = .4, rim = true })
local rI, rT = O.shadeN(c, rm, rn, BARK, { amb = .22, wrap = .4, rim = true, sep = BARK[1] })
O.tex(c, rI, rT, BARK, function(x, y, i) if (x - y * .3) % 3 < 1 then return -1 end end)
O.tex(c, lI, lT, BARK, function(x, y, i) if (x + y * .3) % 3 < 1 then return -1 end end)
O.mark(c, { { 8, 10 }, { 7, 12 }, { 9, 9 } }, MOSS[3]) O.mark(c, { { 8, 11 }, { 7, 13 } }, MOSS[2])

c:paint({
  "..c..",
  ".bbb.",
  "aabba",
  ".fef.",
  ".edd.",
  "..d..",
}, 21, 9, { a = CAP[3], b = CAP[5], c = CAP[2], d = NUT[3], e = NUT[4], f = NUT[5] })

local ball = c:ellipse(18, 24, 8, 7)
local bI, bT = O.shade(c, ball, SILK, { sphere = { 15, 20, 12 }, amb = .3, wrap = .45, rim = true, bounce = "#8a7aa8", bmax = 2 })
O.tex(c, bI, bT, SILK, function(x, y, i)
  if y >= 19 and y <= 30 and x >= 12 and x <= 24 then return 0 end
  if (x + y * 1.4) % 5 < 1 or (x - y * .9 + 60) % 5 < 1 then return -1 end
end)
for _, w in ipairs({ { { 11, 24 }, { 9, 22 }, { 7, 22 }, { 6, 23 } }, { { 25, 24 }, { 27, 22 }, { 29, 22 }, { 30, 23 } } }) do
  local m, n = O.tube(w, function() return .6 end)
  O.shadeN(c, m, n, SILK, { amb = .35, wrap = .45 })
end
O.dot(c, 13, 25, P.petal.base) O.dot(c, 23, 25, P.petal.base)
O.dots(c, { { 17, 26 }, { 18, 27 }, { 19, 26 } }, P.ink)

O.done(c, "pl-sbs-3-perch", function(c)
  c:eyeSmall(15, 22)
  c:eyeSmall(20, 22)
  c:put(14, 20, P.ink) c:put(15, 20, P.ink) c:put(20, 20, P.ink) c:put(21, 20, P.ink)
end)
