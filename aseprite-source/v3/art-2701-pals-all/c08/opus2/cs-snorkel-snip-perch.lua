-- Snorkel Snip (cs-snorkel-snip), perch sprite 36x36. Opus second pass, hand-built at this size: round pink body,
-- teal flippers, mask strap on the brow, a bold orange snorkel up the right side, a 5 px ribbed scallop in the
-- left hand and a cream whelk in the right, 2x3 pill eyes and a wide grin.
-- quirk: one bubble rising from the snorkel top.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, P = O.HP, O.P
local c = O.canvas("cs-snorkel-snip-perch", 36)

local PINK = { "#5e2048", "#9a3462", "#cc4f7e", "#ef7a9a", "#ffa9bc", "#ffd6de" }
local TEAL = { "#173f4f", "#1f6a72", "#2f9a94", "#4fc4b0", "#8ae6c8", "#c8f7e2" }
local ORNG = { "#7a2e1c", "#b8481f", "#e0702a", "#f59a3a", "#ffc46a", "#ffe6a8" }
local SCAL = { "#6e3a3a", "#a85a4a", "#d8846a", "#f2ad8a", "#ffd2b2", "#fff0dc" }
local WHLK = { "#4e3a5e", "#7e6488", "#ad94ac", "#d4bfc8", "#efe0dc", "#fff4e8" }

c:groundShadow(18, 32, 11, 1.5)
-- flippers
for _, s in ipairs({ { 12, -1 }, { 24, 1 } }) do
  O.shade(c, c:ellipse(s[1] + s[2], 30.5, 4, 1.5), TEAL, { R = 1, amb = .3, sep = TEAL[1] })
end
-- arms
for _, d in ipairs({ -1, 1 }) do
  local m, n = O.tube({ { 18 + d * 6, 22 }, { 18 + d * 9, 21 }, { 18 + d * 10, 17 }, { 18 + d * 11, 13 } }, function() return 1.4 end)
  O.shadeN(c, m, n, PINK, { amb = .3, sep = PINK[2] })
end
-- body
local body = c:ellipse(18, 22, 8.5, 7.5)
O.shade(c, body, PINK, { sphere = { 15, 18, 10 }, amb = .27, wrap = .35, sep = PINK[1], rim = true, bounce = "#7a4f9a", bmax = 2 })
O.shade(c, c:ellipse(18, 26, 4.5, 3), { "#ffa9bc", "#ffd6de", "#fff0ee" }, { R = 2, amb = .45, cuts = { .4, .75 } })
-- mask strap + lens frame on the brow
local strap = c:rect(10, 16, 26, 16) strap:clip(body)
O.flat(c, strap, TEAL[2], "strap")
O.shade(c, c:rrect(13, 14, 23, 17, 1), TEAL, { R = 1, amb = .35, sep = TEAL[1] })
O.flat(c, c:rect(14, 15, 17, 16), "#8bc4ea", "glass") O.flat(c, c:rect(19, 15, 22, 16), "#8bc4ea", "glass")
O.dots(c, { { 14, 15 }, { 19, 15 } }, "#e4f6ff")
-- snorkel
local tm, tn = O.tube({ { 21, 25 }, { 24, 25 }, { 26, 22 }, { 26, 8 } }, function() return 1 end)
O.shadeN(c, tm, tn, ORNG, { amb = .35, sep = ORNG[1] })
O.shade(c, c:rect(25, 6, 27, 8), TEAL, { R = 1, amb = .4 })
O.flat(c, c:rect(21, 24, 22, 25), TEAL[3], "mouthpiece")
-- scallop (left hand)
do
  local cx, cy = 7, 11
  local fan = c:ellipse(cx, cy, 3.5, 3) fan:cut(c:rect(0, cy + 2, 12, 20))
  fan:add(c:poly{ { cx - 3, cy + 1 }, { cx + 3, cy + 1 }, { cx, cy + 4 } })
  local fI, fT = O.shade(c, fan, SCAL, { sphere = { cx - 1, cy - 2, 5 }, amb = .3, wrap = .4, sep = SCAL[1] })
  O.mark(c, { { cx - 2, cy }, { cx, cy - 1 }, { cx, cy }, { cx + 2, cy }, { cx, cy + 1 } }, SCAL[2])
  O.shade(c, c:rect(cx - 1, cy + 4, cx + 2, cy + 5), PINK, { R = 1, amb = .35, sep = PINK[1] })
end
-- whelk (right hand) sits beside the snorkel
do
  local cx, cy = 30, 11
  local sh = c:ellipse(cx, cy + 1, 2.5, 3)
  sh:add(c:poly{ { cx - 1, cy - 1 }, { cx, cy - 5 }, { cx + 1, cy - 1 } })
  O.shade(c, sh, WHLK, { sphere = { cx - 1, cy - 1, 5 }, amb = .45, wrap = .4, sep = WHLK[1] })
  O.dots(c, { { cx - 1, cy }, { cx, cy }, { cx + 1, cy + 1 } }, WHLK[2])
  O.dot(c, cx + 1, cy + 2, "#f5809f")
end
-- face
c:eyeSmall(14, 19)
c:eyeSmall(21, 19)
O.dots(c, { { 11, 22 }, { 25, 22 } }, "#f5809f")
O.dots(c, { { 15, 23 }, { 16, 24 }, { 17, 24 }, { 18, 24 }, { 19, 24 }, { 20, 24 }, { 21, 23 } }, P.ink)

O.done(c, "cs-snorkel-snip-perch", function(c)
  for _, d in ipairs({ { 0, -1 }, { -1, 0 }, { 1, 0 }, { 0, 1 } }) do c:put(28 + d[1], 3 + d[2], "#3a86b0") end
  c:put(28, 3, "#e4f6ff")
end)
