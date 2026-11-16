-- Acacia Antler (th-acacia-antler), perch sprite 36x36. Opus second pass (c05/opus2), hand-built at this size.
-- Bold and few: leafy olive ball with leaf ears, pill eyes and a bark nose; two forked twig antlers, a straw
-- weaver nest hanging from each outer tine and one from each inner tine.
-- quirk: the yellow weaver bird peeking out of the right outer nest.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("th-acacia-antler-perch", 36)

local LEAF  = { "#1f3a2a", "#2f5a35", "#4a7d3c", "#6fa047", "#9cc25a", "#c8e080" }
local BARK  = { "#2e1f1f", "#4d3326", "#704a32", "#946a45", "#b88c5c", "#d6ae7c" }
local STRAW = { "#5a3e1a", "#8a6428", "#b88f3a", "#dcb85a", "#f2dc8a" }
local BIRD  = { "#8a6a12", "#e0b820", "#f8e060" }
local BNC   = "#4f6a7a"

c:groundShadow(18, 32, 8, 1.5)
for _, lx in ipairs({ 15, 21 }) do
  O.shade(c, c:rect(lx - 1, 28, lx + 1, 31), BARK, { R = 1, amb = .3, sep = BARK[1] })
  O.mark(c, { { lx - 1, 31 }, { lx, 31 }, { lx + 1, 31 } }, BARK[1])
end
for _, b in ipairs({
  { { 15, 19 }, { 13, 14 }, { 11, 10 }, { 10, 5 } }, { { 12, 12 }, { 9, 11 }, { 6, 10 }, { 5, 8 } },
  { { 21, 19 }, { 23, 14 }, { 25, 10 }, { 26, 5 } }, { { 24, 12 }, { 27, 11 }, { 30, 10 }, { 31, 8 } } }) do
  local m, n = O.tube(b, function(t) return .9 - t * .3 end)
  O.shadeN(c, m, n, BARK, { amb = .3, cuts = { .3, .5, .7, .85 }, sep = BARK[1] })
end
local spout = {}
for i, n in ipairs({ { 5, 8, 5, 13 }, { 31, 8, 31, 13 }, { 10, 5, 7, 6 }, { 26, 5, 29, 6 } }) do
  local tx, ty, cx, cy = n[1], n[2], n[3], n[4]
  if i <= 2 then O.dot(c, tx, ty + 1, STRAW[2]) else O.dot(c, (tx + cx) // 2, ty, STRAW[2]) end
  local m = c:ellipse(cx, cy, 1.5, 2)
  if i > 2 then m = c:ellipse(cx, cy + 1, 1, 1.5) end
  O.shade(c, m, STRAW, { R = 1, amb = .35, cuts = { .25, .5, .75, .9 }, sep = STRAW[1] })
  spout[i] = { cx, (i > 2) and cy + 3 or cy + 3 }
  O.dot(c, cx, spout[i][2], STRAW[2])
end

local body = c:ellipse(18, 23, 7.5, 6.5)
local bI, bT = O.shade(c, body, LEAF, { sphere = { 16, 20, 9 }, amb = .3, wrap = .4, rim = true, bounce = BNC, bmax = 2 })
O.tex(c, bI, bT, LEAF, function(x, y, i)
  if y > 19 and y < 27 and x > 12 and x < 24 then return nil end
  if (x * 2 + y) % 5 == 0 and y % 2 == 0 and i <= 5 then return 1 end
end)
O.shade(c, c:poly{ { 12, 19 }, { 8, 17 }, { 7, 18 }, { 10, 21 } }, LEAF, { R = 1, amb = .4, sep = LEAF[1] })
O.shade(c, c:poly{ { 24, 19 }, { 28, 17 }, { 29, 18 }, { 26, 21 } }, LEAF, { R = 1, amb = .35, sep = LEAF[1] })

c:eyeSmall(14, 20) c:eyeSmall(20, 20)
O.flat(c, c:rect(17, 24, 18, 24), BARK[3], "nose") O.dot(c, 17, 24, BARK[5])
O.mark(c, { { 16, 26 }, { 17, 27 }, { 18, 27 }, { 19, 26 } }, P.ink)
O.dot(c, 12, 24, "#f5809f") O.dot(c, 24, 24, "#f5809f")

-- weaver bird under the right outer nest
local sx, sy = spout[2][1], spout[2][2]
O.flat(c, c:rect(sx - 1, sy + 1, sx, sy + 2), BIRD[2], "bird")
O.dot(c, sx - 1, sy + 1, BIRD[3]) O.dot(c, sx, sy + 1, P.ink) O.dot(c, sx + 1, sy + 2, "#c86a2a")

O.done(c, "th-acacia-antler-perch")
