-- Koi Kin (br-koi-kin), perch sprite 36x36. Opus second pass (art-2701-pals-all/c06/opus2), hand-built at this size.
-- Same design as the yard, fewer and bolder parts: orange koi swimming at the surface of a stone-rimmed oval
-- pond, head to the left turned to us, cream back patch, dorsal fin, tail fan flicking up at the right,
-- and three orange cousins under the water. Face: c:eyeSmall pills, round mouth, cheek.
-- quirk: one cousin pops its head up by the tail and blows a bubble.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("br-koi-kin-perch", 36)

local KOI  = { "#5a1c1a", "#8e2e1c", "#c4501e", "#ec7a2a", "#f8a44a", "#ffd08a" }
local CRM  = { "#c49a86", "#e6c8b0", "#f8e6d2", "#fff6ea" }
local FIN  = { "#8e2e1c", "#d0602a", "#f49a5a", "#ffc89a", "#ffe6cc" }
local STON = { "#3a3446", "#58526a", "#7c7890", "#a4a2b4", "#c8c8d2" }
local WAT  = { "#14364a", "#1c4e62", "#24687a", "#358a94", "#5aaeac", "#9cd6cc" }
local SUB  = { "#9a4a2a", "#c86a32" }

O.shade(c, c:ellipse(18, 27, 16, 6), STON, { R = 1, amb = .28, wrap = .4, rim = true, cuts = { .25, .45, .65, .85 } })
local water = c:ellipse(18, 27, 13.5, 4)
local wb = {} water:each(function(x, y) wb[K(x, y)] = -1 end)
O.shade(c, water, WAT, { R = 2, amb = .3, bias = wb, sep = STON[1] })
for _, f in ipairs({ { 7, 28, 1 }, { 16, 30, 1 }, { 25, 28, 1 } }) do
  local x, y, d = f[1], f[2], f[3]
  for i = 0, 2 do c:put(x + i * d, y, SUB[2]) end
  c:put(x + 3 * d, y - 1, SUB[1]) c:put(x + 3 * d, y + 1, SUB[1]) c:put(x, y, "#f0a060")
end

O.shade(c, c:poly{ { 27, 22 }, { 31, 16 }, { 34, 12 }, { 33, 17 }, { 35, 17 }, { 30, 24 } }, FIN, { R = 1, amb = .3, sep = FIN[1], cuts = { .25, .45, .65, .85 } })
O.shade(c, c:poly{ { 12, 16 }, { 17, 12 }, { 23, 13 }, { 25, 17 } }, FIN, { R = 1, amb = .35, sep = FIN[1], cuts = { .25, .45, .65, .85 } })
local body = c:ellipse(16, 20, 11, 6)
body:add(c:ellipse(26, 21, 4, 3))
body:cut(c:rect(0, 26, 35, 35))
O.shade(c, body, KOI, { sphere = { 12, 16, 13 }, amb = .28, wrap = .35, sep = KOI[1], rim = true })
local patch = c:ellipse(21, 17, 3.5, 2) patch:clip(body)
O.shade(c, patch, CRM, { R = 1, amb = .45, cuts = { .3, .55, .8 } })
O.mark(c, { { 7, 25 }, { 8, 25 }, { 22, 25 }, { 23, 25 } }, WAT[6])

c:eyeSmall(8, 17) c:eyeSmall(14, 17)
O.dots(c, { { 7, 22 }, { 8, 22 }, { 6, 23 }, { 9, 23 } }, P.ink)
O.dots(c, { { 7, 23 }, { 8, 23 } }, "#7a2a30")
c:cheek(16, 21)

O.shade(c, c:ellipse(31, 25, 1.5, 1.5), KOI, { R = 1, amb = .4, sep = KOI[1] })
O.dot(c, 30, 25, P.ink)

O.shift(c, 0, -5)
O.done(c, "br-koi-kin-perch", function(c)
  for _, p in ipairs({ { 33, 15 }, { 34, 16 }, { 33, 17 }, { 32, 16 } }) do
    if not c.pix[p[2] * c.w + p[1]] then c:put(p[1], p[2], WAT[6]) end
  end
end)
