-- Tall Tiptoe (th-tall-tiptoe), perch sprite 36x36. Opus richness pass (c05/opus3), hand-built at this size.
-- Richness pass: hue-shifted ramps, patches with a darker lower edge, two-tone mane, lit hooves, a red-billed
-- oxpecker (3 px) on the back.
-- Bold and few: slim legs with dark hooves, small patched body, a long diagonal neck with a mane line and a
-- big round head facing you (pill eyes in tan sockets, pale muzzle, ossicones with dark tufts, side ears).
-- Fix vs Haiku: the leaf is no longer pressed against the head; it is a separate sprig up and to the right.
-- quirk: the purple tongue curling up to hook the acacia leaves.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("th-tall-tiptoe-perch", 36)

local CRM  = { "#6e4c34", "#a8783e", "#d4a65a", "#eac88a", "#f6e2b4", "#fcf2da" }
local PAT  = { "#3a1f1a", "#5c2f1f", "#7e4128", "#a05630", "#bc6c3a", "#d4844a" }
local MUZ  = { "#a07c62", "#cfae8e", "#ead2b4", "#f8e8d2" }
local HOOF = { "#2e2230", "#4a3a44", "#6a5660" }
local TONG = { "#3a2a5e", "#5a4490", "#7e68b8", "#a690d6" }
local LEAF = { "#1f3a2a", "#2f5a35", "#4a7d3c", "#6fa047", "#9cc25a", "#c8e080" }
local BNC  = "#6a6080"

c:groundShadow(14, 32, 9, 1)
for _, L in ipairs({ { 9, true }, { 18, true }, { 5 }, { 14 } }) do
  O.flat(c, c:rect(L[1], 24, L[1], 30), L[2] and CRM[2] or CRM[4], "leg")
  O.flat(c, c:rect(L[1] + 1, 24, L[1] + 1, 30), L[2] and CRM[1] or CRM[3], "leg")
  O.flat(c, c:rect(L[1], 31, L[1] + 1, 31), HOOF[2], "hoof") O.dot(c, L[1], 31, HOOF[3])
end
O.flat(c, c:line({ { 5, 21 }, { 3, 24 } }, 1), CRM[2], "tail") O.dot(c, 3, 25, HOOF[2])

local body = c:ellipse(12, 21.5, 7, 3.5)
local bI, bT = O.shade(c, body, CRM, { R = 3, amb = .25, wrap = .4, rim = true, bounce = BNC, bmax = 2 })
O.mark(c, { { 8, 20 }, { 9, 20 }, { 9, 21 }, { 13, 20 }, { 14, 20 }, { 14, 21 }, { 11, 23 }, { 12, 23 }, { 16, 22 }, { 17, 22 }, { 6, 22 } }, PAT[4])
O.mark(c, { { 9, 21 }, { 14, 21 }, { 12, 23 }, { 17, 22 } }, PAT[3])

local nk, nkn = O.tube({ { 16, 20 }, { 19, 16 }, { 21, 13 }, { 23, 10 } }, function(t) return 2 - t * .6 end)
O.shadeN(c, nk, nkn, CRM, { amb = .25, wrap = .4, rim = true, bounce = BNC, bmax = 2 })
O.mark(c, { { 17, 17 }, { 18, 16 }, { 20, 13 } }, PAT[4]) O.mark(c, { { 21, 15 }, { 19, 18 } }, PAT[3])
O.mark(c, { { 15, 18 }, { 17, 15 }, { 19, 12 } }, PAT[2]) -- mane
O.mark(c, { { 16, 17 }, { 18, 14 } }, PAT[4])
-- oxpecker on the back
O.flat(c, c:rect(9, 17, 11, 17), "#a8845c", "ox") O.dot(c, 11, 16, "#7a5a3e") O.dot(c, 9, 17, "#6a4a36") O.dot(c, 12, 16, "#d8382a")

local head = c:ellipse(24, 8.5, 5.5, 4.5)
O.shade(c, head, CRM, { sphere = { 23, 7, 6 }, amb = .3, wrap = .4, rim = true, bounce = BNC, bmax = 2 })
O.shade(c, c:ellipse(17.5, 6.5, 1.5, 1), CRM, { R = 1, amb = .35, sep = CRM[1] })
O.shade(c, c:ellipse(30.5, 6.5, 1.5, 1), CRM, { R = 1, amb = .3, sep = CRM[1] })
for _, ox in ipairs({ 22, 26 }) do
  O.flat(c, c:rect(ox, 2, ox, 4), CRM[3], "oss")
  O.flat(c, c:rect(ox - 1, 1, ox + 1, 1), PAT[2], "tuft")
end
local mz = c:ellipse(24, 11.5, 3, 1.5)
O.shade(c, mz, MUZ, { R = 1, amb = .45, cuts = { .3, .55, .8 }, sep = CRM[1] })
O.dots(c, { { 23, 12 }, { 24, 12 }, { 25, 12 } }, P.ink)
for _, ex in ipairs({ 21, 26 }) do
  O.mark(c, { { ex - 1, 6 }, { ex - 1, 7 }, { ex - 1, 8 }, { ex + 2, 6 }, { ex + 2, 7 }, { ex + 2, 8 } }, CRM[3])
  c:eyeSmall(ex, 6)
end
O.dot(c, 19, 10, "#f5809f") O.dot(c, 29, 10, "#f5809f")

-- tongue up to the leaf sprig
O.flat(c, c:line({ { 27, 12 }, { 29, 13 }, { 30, 12 }, { 31, 10 } }, 1), TONG[3], "tongue")
O.dot(c, 31, 10, TONG[4]) O.dot(c, 29, 13, TONG[2])
O.flat(c, c:line({ { 32, 3 }, { 31, 8 } }, 1), "#64402c", "twig")
for _, lf in ipairs({ { 30, 5 }, { 32, 7 }, { 32, 3 } }) do
  O.shade(c, c:ellipse(lf[1], lf[2], 1, 1), LEAF, { R = 1, amb = .4, cuts = { .3, .6, .85 }, sep = LEAF[1] })
end

O.shift(c, 0, 1)
O.done(c, "th-tall-tiptoe-perch")
