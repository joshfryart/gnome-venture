-- Snorkel Snip (cs-snorkel-snip), perch sprite 36x36. Opus richness pass (c08/opus3), hand-built at this size:
-- round pink body (hue-shifted ramp, rim light, violet bounce), ribbed teal flippers, mask frame on the brow with a
-- glass glint, a bold orange snorkel with one dark band, a ribbed scallop in the left hand, a whelk in the right,
-- 2x3 pill eyes and a wide grin. Fewer, bolder marks than the yard.
-- quirk: one bubble rising from the snorkel top. closer look: a 3 px wisp of seaweed snagged on the snorkel.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, P = O.HP, O.P
local c = O.canvas("cs-snorkel-snip-perch", 36)

local PINK = { "#4c1f4c", "#8c3064", "#c44c7c", "#ec7896", "#ffa6b2", "#ffd8d0" }
local TEAL = { "#173a52", "#1d6474", "#2a9496", "#4cc2ae", "#8ae6c4", "#d0f6dc" }
local ORNG = { "#6e2a26", "#b0441e", "#dc6c26", "#f59a38", "#ffc868", "#ffeaa8" }
local SCAL = { "#64323e", "#a2564a", "#d4806a", "#f0aa86", "#ffd2aa", "#fff0d6" }
local WHLK = { "#46385e", "#76608a", "#a890aa", "#d2bcc4", "#eee0da", "#fff4e4" }
local BNC = "#6e5aa4"

c:groundShadow(18, 32, 11, 1.5)
-- flippers with one rib each
for _, s in ipairs({ { 12, -1 }, { 24, 1 } }) do
  O.shade(c, c:ellipse(s[1] + s[2], 30.5, 4, 1.5), TEAL, { R = 1, amb = .3, sep = TEAL[1], rim = true })
  O.mark(c, { { s[1] + s[2] * 3, 31 } }, TEAL[2])
end
-- arms
for _, d in ipairs({ -1, 1 }) do
  local m, n = O.tube({ { 18 + d * 6, 22 }, { 18 + d * 9, 21 }, { 18 + d * 10, 17 }, { 18 + d * 11, 13 } }, function() return 1.4 end)
  O.shadeN(c, m, n, PINK, { amb = .3, sep = PINK[2], rim = true })
end
-- body
local body = c:ellipse(18, 22, 8.5, 7.5)
O.shade(c, body, PINK, { sphere = { 15, 18, 10 }, amb = .27, wrap = .35, sep = PINK[1], rim = true, bounce = BNC, bmax = 2 })
O.shade(c, c:ellipse(18, 26, 4.5, 3), { "#f8a2b0", "#ffcec8", "#fff0e2" }, { R = 2, amb = .45, cuts = { .4, .75 } })
-- mask frame + glass on the brow
O.shade(c, c:rrect(13, 14, 23, 17, 1), TEAL, { R = 1, amb = .35, sep = TEAL[1], rim = true })
O.flat(c, c:rect(14, 15, 17, 16), "#8bc4ea", "glass") O.flat(c, c:rect(19, 15, 22, 16), "#8bc4ea", "glass")
O.dots(c, { { 14, 15 }, { 15, 15 }, { 19, 15 }, { 20, 15 } }, "#e4f6ff")
O.dots(c, { { 17, 16 }, { 22, 16 } }, "#3a86b0")
-- snorkel
local tm, tn = O.tube({ { 21, 25 }, { 24, 25 }, { 26, 22 }, { 26, 8 } }, function() return 1 end)
O.shadeN(c, tm, tn, ORNG, { amb = .35, sep = ORNG[1], rim = true })
O.shade(c, c:rect(25, 6, 27, 8), TEAL, { R = 1, amb = .4, sep = TEAL[1] })
O.dot(c, 25, 6, TEAL[6])
O.mark(c, { { 25, 15 }, { 26, 15 }, { 27, 15 } }, ORNG[2])
O.flat(c, c:rect(21, 24, 22, 25), TEAL[3], "mouthpiece") O.dot(c, 21, 24, TEAL[5])
-- seaweed wisp hooked over the snorkel
O.dots(c, { { 24, 10 }, { 24, 11 } }, "#3f9150") O.dot(c, 25, 9, "#7cc35a") O.dot(c, 23, 12, "#24544a")
-- scallop (left hand)
do
  local cx, cy = 7, 11
  local fan = c:ellipse(cx, cy, 3.5, 3) fan:cut(c:rect(0, cy + 2, 12, 20))
  fan:add(c:poly{ { cx - 3, cy + 1 }, { cx + 3, cy + 1 }, { cx, cy + 4 } })
  O.shade(c, fan, SCAL, { sphere = { cx - 1, cy - 2, 5 }, amb = .3, wrap = .4, sep = SCAL[1], rim = true })
  O.mark(c, { { cx - 2, cy }, { cx - 2, cy - 1 }, { cx, cy - 1 }, { cx, cy }, { cx + 2, cy }, { cx + 2, cy - 1 }, { cx, cy + 1 } }, SCAL[2])
  O.shade(c, c:rect(cx - 1, cy + 4, cx + 2, cy + 5), PINK, { R = 1, amb = .35, sep = PINK[1] })
end
-- whelk (right hand) beside the snorkel
do
  local cx, cy = 30, 11
  local sh = c:ellipse(cx, cy + 1, 2.5, 3)
  sh:add(c:poly{ { cx - 1, cy - 1 }, { cx, cy - 5 }, { cx + 1, cy - 1 } })
  O.shade(c, sh, WHLK, { sphere = { cx - 1, cy - 1, 5 }, amb = .45, wrap = .4, sep = WHLK[1], rim = true })
  O.dots(c, { { cx - 1, cy }, { cx, cy }, { cx + 1, cy + 1 } }, WHLK[2])
  O.dots(c, { { cx, cy - 3 } }, WHLK[3])
  O.dot(c, cx + 1, cy + 2, "#f5809f")
end
-- face
c:eyeSmall(14, 19)
c:eyeSmall(21, 19)
O.dots(c, { { 11, 22 }, { 25, 22 } }, "#f5809f")
O.dots(c, { { 15, 23 }, { 16, 24 }, { 17, 24 }, { 18, 24 }, { 19, 24 }, { 20, 24 }, { 21, 23 } }, P.ink)
O.dots(c, { { 17, 25 }, { 18, 25 } }, PINK[2])

O.done(c, "cs-snorkel-snip-perch", function(c)
  for _, d in ipairs({ { 0, -1 }, { -1, 0 }, { 1, 0 }, { 0, 1 } }) do c:put(28 + d[1], 3 + d[2], "#3a86b0") end
  c:put(28, 3, "#e4f6ff")
end)
