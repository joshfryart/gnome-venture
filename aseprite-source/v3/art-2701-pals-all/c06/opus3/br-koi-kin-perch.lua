-- Koi Kin (br-koi-kin), perch sprite 36x36. Opus richness pass (c06/opus3), hand-built at this size.
-- Same design as the yard, fewer and bolder parts: orange koi at the surface of a stone-rimmed oval pond, head
-- to the left turned to us, cream back patch, dorsal fin, tail fan flicking up at the right.
-- Fixes the opus2 weakness: the two cousins under the water are bold 6x3 fish (lit back, eye, tail fork) in
-- bright orange, readable at 1x. Richness: stone seams on the rim, scale marks, fin rays.
-- Face: c:eyeSmall pills, round mouth, cheek. quirk: one cousin pops its head up by the tail, blowing a bubble.
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

local sI, sT = O.shade(c, c:ellipse(18, 27, 16, 6), STON, { R = 1, amb = .28, wrap = .4, rim = true, cuts = { .25, .45, .65, .85 } })
local function stone(x, y) return math.floor((math.atan((y - 27) / 6, (x - 18) / 16) / (2 * math.pi) + .5) * 14) end
O.tex(c, sI, sT, STON, function(x, y, i) if stone(x, y) ~= stone(x + 1, y) then return -2 end if O.H(stone(x, y), 1, 4) > .6 then return 1 end end)
local water = c:ellipse(18, 27, 13.5, 4)
local wb = {} water:each(function(x, y) wb[K(x, y)] = -1 end)
O.shade(c, water, WAT, { R = 2, amb = .3, bias = wb, sep = STON[1] })
local COUS = { a = "#f8b060", b = "#e0782e", t = "#b85a2a", e = "#3a1c20" }
for _, f in ipairs({ { 5, 28 }, { 18, 29 } }) do
  for j, r in ipairs({ ".aab.t", "ebbbtt", ".bbb.t" }) do for i = 1, #r do
    local ch = r:sub(i, i) if COUS[ch] then c:put(f[1] + i - 1, f[2] + j - 2, COUS[ch]) end
  end end
end
O.shade(c, c:poly{ { 27, 22 }, { 31, 16 }, { 34, 12 }, { 33, 17 }, { 35, 17 }, { 30, 24 } }, FIN, { R = 1, amb = .3, sep = FIN[1], cuts = { .25, .45, .65, .85 } })
O.mark(c, { { 31, 18 }, { 32, 16 }, { 30, 20 } }, FIN[2])
O.shade(c, c:poly{ { 12, 16 }, { 17, 12 }, { 23, 13 }, { 25, 17 } }, FIN, { R = 1, amb = .35, sep = FIN[1], cuts = { .25, .45, .65, .85 } })
local body = c:ellipse(16, 20, 11, 6)
body:add(c:ellipse(26, 21, 4, 3))
body:cut(c:rect(0, 26, 35, 35))
local bI, bT = O.shade(c, body, KOI, { sphere = { 12, 16, 13 }, amb = .28, wrap = .35, sep = KOI[1], rim = true })
O.tex(c, bI, bT, KOI, function(x, y, i) if x >= 18 and y % 2 == 0 and (x + (y // 2) % 2 * 2) % 4 == 0 and i >= 3 then return -1 end end)
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
