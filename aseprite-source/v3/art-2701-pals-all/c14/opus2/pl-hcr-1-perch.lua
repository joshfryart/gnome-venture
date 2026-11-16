-- Lightning Pinch (pl-hcr-1), perch sprite 36x36. Opus second pass (c14/opus2), hand-built at this size.
-- One lightning crab pincer: fat palm with the face (2x3 pill eyes, slanted brows, open snapping mouth),
-- hooked upper finger and lower finger open wide, balanced on a zigzag bolt.
-- quirk: snapping at a tiny sneeze puff, one spark across the jaws.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-hcr-1-perch", 36)

local BOLT = { "#7a3524", "#b8602a", "#e4962c", "#f8c63e", "#ffe57a", "#fff6c4" }
local ZAP  = { "#2c3c78", "#3a6ab0", "#5aa2dc", "#94d2f2", "#d0f0fa" }
local PUFF = { "#76829e", "#b2bfd0", "#dee6ea", "#f6f8ee" }

c:groundShadow(13, 32, 6, 1.5)
local bolt = c:poly{ { 7, 22 }, { 16, 22 }, { 13, 26 }, { 19, 26 }, { 11, 34 }, { 12, 29 }, { 7, 29 } }
O.shade(c, bolt, BOLT, { R = 1, amb = .35, wrap = .45, sep = BOLT[1], bounce = "#b0607a", bmax = 2 })
local lf, ln = O.tube({ { 18, 22 }, { 22, 22 }, { 25, 19 }, { 27, 15 } }, function(t) return 2.4 * (1 - t) ^ .8 + .5 end)
O.shadeN(c, lf, ln, BOLT, { amb = .3, wrap = .4, rim = true, sep = BOLT[1] })
local uf, un = O.tube({ { 16, 13 }, { 18, 6 }, { 24, 3 }, { 28, 8 } }, function(t) return 3.3 * (1 - t) ^ .75 + .5 end)
O.shadeN(c, uf, un, BOLT, { amb = .3, wrap = .4, rim = true, sep = BOLT[1] })
local palm = c:ellipse(12, 17, 7.5, 6.5)
O.shade(c, palm, BOLT, { sphere = { 10, 14, 10 }, amb = .36, wrap = .5, rim = true, bounce = "#b0607a", bmax = 2, sep = BOLT[1] })
O.mark(c, { { 21, 10 }, { 23, 8 }, { 24, 20 } }, BOLT[2]) -- teeth notches
O.mark(c, { { 7, 12 }, { 8, 11 }, { 9, 12 } }, BOLT[3])    -- crackle

c:eyeSmall(8, 15)
c:eyeSmall(14, 15)
O.dots(c, { { 7, 13 }, { 8, 13 }, { 15, 13 }, { 16, 13 } }, P.ink) -- brows
O.dot(c, 6, 19, P.petal.base) O.dot(c, 18, 19, P.petal.base)
O.dots(c, { { 10, 19 }, { 11, 19 }, { 12, 19 }, { 10, 20 }, { 12, 20 }, { 11, 21 } }, P.ink)
O.dot(c, 11, 20, "#8a2a3a")

local PF = { a = PUFF[4], b = PUFF[3], c = PUFF[2], d = PUFF[1] }
local tk = { r = { name = "puff" } }
for j, row in ipairs({ ".ab.", "abbc", "bbcd", ".cd." }) do
  for i = 1, #row do local ch = row:sub(i, i) if PF[ch] then c:put(27 + i, 9 + j, PF[ch], tk) end end
end

O.done(c, "pl-hcr-1-perch", function(c)
  O.dots(c, { { 23, 13 }, { 24, 12 }, { 25, 13 } }, ZAP[5])
end)
