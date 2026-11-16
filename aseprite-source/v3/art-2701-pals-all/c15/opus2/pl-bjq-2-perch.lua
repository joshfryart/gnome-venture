-- Clownfish Peek (pl-bjq-2), perch sprite 36x36. Opus second pass (c15/opus2), hand-built at this size.
-- Round orange clownfish facing us (2x3 pill eyes, little "o" mouth), cream cheek stripes with ink borders and
-- an ink-tipped dorsal fin, peeking over two lavender brain-coral heads with its fins hooked over the edge.
-- quirk: only its face and fins show over the coral, ready to duck (a bubble rising).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-bjq-2-perch", 36)

local FISH = { "#7a2418", "#b8401a", "#e8661e", "#ff8f2e", "#ffb45a", "#ffd890" }
local STR  = { "#b8a0a8", "#e4d6d0", "#fff4e6" }
local BRN  = { "#3c2a62", "#5a4490", "#8068c0", "#a690de", "#c8b6f0", "#e6dcfa" }

c:groundShadow(18, 32, 13, 1)
O.shade(c, c:poly{ { 15, 9 }, { 17, 4 }, { 21, 4 }, { 22, 9 } }, FISH, { R = 1, amb = .35, sep = FISH[1] })
O.mark(c, { { 17, 4 }, { 18, 4 }, { 19, 4 }, { 20, 4 } }, P.ink)
local head = c:ellipse(18, 15, 10, 8)
O.shade(c, head, FISH, { sphere = { 14, 10, 13 }, amb = .3, wrap = .45, rim = true, bounce = "#9a6ad0", bmax = 2 })
head:each(function(x, y)
  local u, v = math.abs(x + .5 - 18) / 10, (y + .5 - 15) / 8
  local d = u / math.sqrt(math.max(.05, 1 - v * v))
  if d > .64 and d < .84 then c.pix[y * c.w + x] = (x < 18 and y < 14) and STR[3] or STR[2]
  elseif d >= .84 and d <= .93 then c.pix[y * c.w + x] = P.ink end
end)
O.mark(c, { { 14, 9 }, { 15, 8 } }, FISH[6])
c:eyeSmall(14, 13)
c:eyeSmall(21, 13)
O.dot(c, 12, 17, P.petal.base) O.dot(c, 24, 17, P.petal.base)
O.mark(c, { { 17, 18 }, { 18, 18 }, { 17, 19 }, { 18, 19 } }, P.ink)

for _, d in ipairs({ { 11, 27, 7.5, 5 }, { 25, 27, 7.5, 5 } }) do
  local dm = c:ellipse(d[1], d[2], d[3], d[4]) dm:cut(c:rect(0, 31, 35, 35))
  local bI, bT = O.shade(c, dm, BRN, { sphere = { d[1] - 3, d[2] - 4, d[3] + 4 }, amb = .3, wrap = .45, rim = true, sep = BRN[1] })
  O.tex(c, bI, bT, BRN, function(x, y, i)
    local u, v = (x + .5 - d[1]) / d[3], (y + .5 - d[2]) / d[4]
    if (math.sqrt(u * u + v * v) * 3 + .3 * math.sin(math.atan(v, u) * 6)) % 1 < .3 then return -1 end
  end)
end
for _, f in ipairs({ { 8, 21 }, { 26, 21 } }) do
  O.shade(c, c:rect(f[1], f[2], f[1] + 2, f[2] + 1), FISH, { R = 1, amb = .4, cuts = { .2, .4, .6, .8, .95 }, sep = FISH[1] })
end

O.done(c, "pl-bjq-2-perch", function(c)
  for _, p in ipairs({ { 28, 3 }, { 29, 3 }, { 27, 4 }, { 30, 4 }, { 28, 5 }, { 29, 5 }, { 25, 7 } }) do if not c:get(p[1], p[2]) then c:put(p[1], p[2], "#b9e2f5") end end
end)
