-- Torii Loop (br-torii-loop), perch sprite 36x36, hand-built at this size (opus2).
-- Round gold hopper with long feet and a cream belly; a red torii gate (black kasagi, nuki, 2 px posts standing
-- clear of the face on the crown); open tail curl with an ember tip. Pill eyes sit low and wide, below the gate.
-- quirk: a short dashed hop loop behind it.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("br-torii-loop-perch", 36)

local GLD = { "#6e3a1c", "#9a5422", "#d98322", "#f5b82e", "#ffd45e", "#ffeca6" }
local BEL = { "#d99a4e", "#efbe72", "#f9d996", "#fff0c4" }
local RED = { "#4a1830", "#7a2238", "#b52e3f", "#e8493b", "#ff6e4e", "#ff9e78" }
local CAP = { "#3a2a3a", "#4e3a4c", "#6a5064", "#8a6c80" }

c:groundShadow(18, 33, 9, 1.2)
-- tail curl
local tl, tn = O.tube({ { 24, 25 }, { 31, 27 }, { 33, 20 }, { 29, 18 } }, function(t) return 1.5 - t * .4 end)
O.shadeN(c, tl, tn, GLD, { amb = .3, wrap = .4, sep = GLD[1] })
O.flat(c, c:rect(28, 17, 29, 18), "#e8493b", "tip") O.dot(c, 28, 17, "#ff8a5c")
-- feet
for _, fx in ipairs({ 11, 25 }) do O.shade(c, c:ellipse(fx, 31, 4, 1.3), GLD, { R = 1, amb = .3, sep = GLD[1] }) end
-- body
local body = c:ellipse(18, 23, 8.5, 8)
O.shade(c, body, GLD, { sphere = { 14, 18, 12 }, amb = .36, wrap = .45, sep = GLD[1], rim = true, bounce = "#a86a6a", bmax = 2 })
local bel = c:ellipse(18, 28, 4.5, 3) bel:clip(body)
O.shade(c, bel, BEL, { R = 2, amb = .45, cuts = { .3, .55, .8 } })
-- torii: posts first, then beams
for _, px in ipairs({ 12, 23 }) do
  local yb = 6 while not body:has(px, yb) do yb = yb + 1 end
  O.shade(c, c:rect(px, 6, px + 1, yb), RED, { R = 1, amb = .35, sep = RED[1] })
  O.flat(c, c:rect(px, yb - 1, px + 1, yb), CAP[2], "kamaki")
end
O.shade(c, c:rect(9, 9, 27, 10), RED, { R = 1, amb = .35, sep = RED[1] })
O.shade(c, c:rect(10, 5, 26, 6), RED, { R = 1, amb = .35, sep = RED[1] })
O.shade(c, c:poly{ { 7, 2 }, { 10, 3 }, { 26, 3 }, { 29, 2 }, { 28, 4 }, { 8, 4 } }, CAP, { R = 1, amb = .4, cuts = { .3, .55, .8 } })
O.flat(c, c:rect(17, 7, 18, 8), "#f5b82e", "plaque")
-- face
c:eyeSmall(14, 20)
c:eyeSmall(21, 20)
O.dot(c, 11, 24, "#f5809f") O.dot(c, 25, 24, "#f5809f")
O.dots(c, { { 17, 25 }, { 18, 26 }, { 19, 25 } }, "#5a2420")

O.done(c, "br-torii-loop-perch", function(c)
  for _, p in ipairs({ { 2, 32 }, { 3, 30 }, { 4, 27 }, { 3, 25 }, { 5, 23 }, { 7, 24 }, { 7, 27 }, { 8, 20 } }) do
    if not c:get(p[1], p[2]) then c:put(p[1], p[2], "#8bc4ea", { r = { name = "trail" } }) end
  end
end)
