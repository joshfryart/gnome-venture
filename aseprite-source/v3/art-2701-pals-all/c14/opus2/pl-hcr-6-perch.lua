-- Gale Islander (pl-hcr-6), perch sprite 36x36. Opus second pass (c14/opus2), hand-built at this size.
-- Coral pocket crab with raised claws and three legs a side, a sand island with a foam ring on its back and
-- one big wind-bent palm (ringed trunk, fronds streaming right, coconuts); 2x3 pill eyes on the shell front.
-- quirk: the palm blowing over in the gale.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-hcr-6-perch", 36)

local CRAB = { "#5e1a34", "#94304a", "#c84e5a", "#e8766a", "#f6a088", "#fcccb0" }
local SAND = { "#7a5040", "#a87a52", "#d2a466", "#ecc884", "#f8e2a8", "#fdf2d0" }
local SEA  = { "#1e5a6e", "#2e8a92", "#52b8b0", "#94dccc", "#d8f4ec" }
local BARK = { "#3e2526", "#5e3a2c", "#86583a", "#b07e50", "#d4a874" }
local FRND = { "#1c4236", "#2a6640", "#3c8c4a", "#62ac50", "#9ccc68", "#d2e89a" }
local NUT  = { "#3e2526", "#6a4030", "#94603e", "#c08a58" }

c:groundShadow(18, 32, 12, 1.5)
for _, L in ipairs({ { { 12, 27 }, { 9, 28 }, { 7, 30 }, { 7, 32 } }, { { 14, 28 }, { 12, 30 }, { 11, 31 }, { 11, 32 } }, { { 16, 29 }, { 15, 31 }, { 15, 32 }, { 15, 32 } },
                     { { 24, 27 }, { 27, 28 }, { 29, 30 }, { 29, 32 } }, { { 22, 28 }, { 24, 30 }, { 25, 31 }, { 25, 32 } }, { { 20, 29 }, { 21, 31 }, { 21, 32 }, { 21, 32 } } }) do
  local m, n = O.tube(L, function() return .8 end)
  O.shadeN(c, m, n, CRAB, { amb = .35, wrap = .4, sep = CRAB[1] })
end
for _, d in ipairs({ -1, 1 }) do
  local arm, an = O.tube({ { 18 + d * 7, 26 }, { 18 + d * 9.5, 26 }, { 18 + d * 11, 24.5 }, { 18 + d * 11, 22.5 } }, function() return 1.1 end)
  O.shadeN(c, arm, an, CRAB, { amb = .35, wrap = .4, sep = CRAB[1] })
  local cl = c:ellipse(18 + d * 11, 20.5, 2.3, 2.3)
  cl:cut(c:poly{ { 18 + d * 11, 20 }, { 18 + d * 10, 17.5 }, { 18 + d * 12.3, 17.5 } })
  O.shade(c, cl, CRAB, { sphere = { 18 + d * 11 - 1, 19, 4 }, amb = .35, wrap = .45, sep = CRAB[1] })
end
local body = c:ellipse(18, 25, 8.5, 4.8)
O.shade(c, body, CRAB, { sphere = { 15, 22, 10 }, amb = .32, wrap = .45, rim = true, bounce = "#7a5a8a", bmax = 2 })
local sea = c:ellipse(18, 20, 7.5, 1.6)
O.shade(c, sea, SEA, { R = 1, amb = .4, wrap = .5, cuts = { .25, .45, .65, .85 }, sep = CRAB[1] })
local mound = c:ellipse(18, 19, 6, 3.5) mound:cut(c:rect(0, 20, 35, 35))
O.shade(c, mound, SAND, { sphere = { 16, 16, 7 }, amb = .35, wrap = .5, rim = true })
local tm, tn, tT = O.tube({ { 16, 19 }, { 15, 14 }, { 17, 10 }, { 20, 8 } }, function(t) return 1.2 - .3 * t end)
local tI, tTk = O.shadeN(c, tm, tn, BARK, { amb = .35, wrap = .45, sep = BARK[1], cuts = { .25, .45, .65, .85 } })
O.tex(c, tI, tTk, BARK, function(x, y, i) local t = tT[K(x, y)] if t and (t * 6) % 1 < .2 then return -1 end end)
for _, o in ipairs({ { 19, 10 }, { 21, 10.5 } }) do
  O.shade(c, c:ellipse(o[1], o[2], 1, 1), NUT, { sphere = { o[1] - 1, o[2] - 1, 2 }, amb = .35, cuts = { .3, .6, .85 }, sep = NUT[1] })
end
for _, f in ipairs({ { 6, -2, 9, 0 }, { 5, 2, 7, 5 }, { -4, -1, -5, 2 }, { 2, -4, 6, -4 } }) do
  local a = { 20, 8 } local b = { 20 + f[1] * .5, 8 + f[2] * .5 - 1.5 } local e = { 20 + f[3], 8 + f[4] }
  local m, n, T, S = O.tube({ a, b, b, e }, function(t) return 1.3 * math.sin(math.pi * math.min(1, t * 1.2)) + .4 end)
  local I, Tk = O.shadeN(c, m, n, FRND, { amb = .22, wrap = .35, sep = FRND[1] })
  O.tex(c, I, Tk, FRND, function(x, y, i) local v = S[K(x, y)] if v and math.abs(v) < .25 then return 1 end end)
end
c:eyeSmall(14, 23)
c:eyeSmall(21, 23)
O.dot(c, 12, 26, P.petal.base) O.dot(c, 24, 26, P.petal.base)
O.dots(c, { { 17, 27 }, { 18, 27 }, { 19, 27 } }, P.ink) O.dots(c, { { 16, 26 }, { 20, 26 } }, P.ink)

O.done(c, "pl-hcr-6-perch", function(c)
  for _, p in ipairs({ { 30, 4 }, { 31, 4 }, { 32, 5 }, { 3, 12 }, { 4, 12 } }) do if not c:get(p[1], p[2]) then O.dot(c, p[1], p[2], "#d8e8ee") end end
end)
