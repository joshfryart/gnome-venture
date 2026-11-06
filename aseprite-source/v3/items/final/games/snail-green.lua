-- snail-green (final pass, Opus single pass). Right-facing garden snail, head lowered to graze: a round, slightly
-- tilted moss-green helix shell with a deep log-spiral suture, lit whorl lips and fine growth ribs; slim olive-cream
-- foot with reticulated skin furrows, frilled sole, wet glints, AO + contact shadow under the shell; eye stalks
-- leaning forward toward its meal.
-- quirk: it is munching a clover leaf that already has a neat bite out of it.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA0_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt = math.floor, math.max, math.min, math.sqrt
local c = A.new("snail-green")
local BODY = { "#5c4a3c", "#8c7a52", "#b6a66a", "#d6ca8a", "#ece2a8", "#fbf4cf" }
local SHELL = { "#173f36", "#22593f", "#2f7a45", "#4d9a4a", "#7cbd57", "#b9df7a" }
local LEAF = { "#1d4a3a", "#28673f", "#3c8a45", "#5aac4c", "#86c95a", "#bfe486" }
local btok, stok = { r = { name = "body" } }, { r = { name = "shell" } }

c:groundShadow(31, 56, 23, 1.5)
-- foot: tail lower-left -> neck rising a little -> head bowed forward
local foot = { { 10, 53 }, { 24, 55.5 }, { 38, 54.5 }, { 45, 47.5 } }
local hw = function(t)
  if t < 0.35 then return 0.6 + 3.0 * (t / 0.35) ^ 0.8 end
  return 3.6 + (t - 0.35) * 1.4
end
local head = c:ellipse(48, 47.5, 4, 3.5)
local hn = X.sphere(47, 46.5, 4.4, head)
local BCUT = { 0.3, 0.48, 0.64, 0.79, 0.92 }
local bm, bn, BT, BS, bidx = A.foot(c, foot, hw, BODY, { tok = btok, add = { { head, hn, 1 } }, cuts = BCUT, amb = 0.05, wrap = 0.2 })
A.skin(c, bm, bidx, BODY, btok)
A.sole(c, bm, BODY, 9, 51, btok)
-- eye stalks leaning forward over the meal (after the body so they sit in front)
A.stalk(c, 47, 45, 49, 33, BODY, btok, 1)
A.stalk(c, 50, 45, 55, 35, BODY, btok, 1)
-- lower feelers + mouth
c:put(52, 50, BODY[3], btok) c:put(53, 50, BODY[2], btok)
c:put(51, 49, BODY[1], btok) c:put(50, 49, BODY[2], btok)
-- wet glints along the lit back of the neck
for _, p in ipairs{ { 40, 49 }, { 43, 46 }, { 46, 44 } } do if bm:has(p[1], p[2]) then c:put(p[1], p[2], BODY[6], btok) end end

-- shell: round, tilted, sits on the back
local SX, SY, R = 24, 38, 12.5
local sm = c:ellipse(SX, SY, R, R - 0.5)
local sidx = A.coil(c, sm, { ramp = SHELL, tok = stok, sx = SX + 2.2, sy = SY - 0.6, a = 1.0, b = 0.21, dir = 1, rot = 0.6,
  cx = SX - 0.8, cy = SY - 0.8, r = R, wS = 0.7, R = 4, ribs = 14, ribTwist = 3 })
-- aperture lip where the body leaves the shell (lower right): pale rim + dark inside
for _, p in ipairs{ { 34, 46 }, { 35, 45 }, { 36, 44 } } do c:put(p[1], p[2], SHELL[6], stok) end
for _, p in ipairs{ { 33, 47 }, { 34, 47 }, { 35, 46 } } do c:put(p[1], p[2], SHELL[1], stok) end
-- AO / contact shadow on the body just below and right of the shell
bm:each(function(x, y) if not sm:has(x, y) then
  if sm:has(x, y - 1) or sm:has(x - 1, y - 1) then A.step(c, bidx, BODY, x, y, -2, btok)
  elseif sm:has(x, y - 2) or sm:has(x - 1, y) then A.step(c, bidx, BODY, x, y, -1, btok) end end end)
-- cool reflected light on the shell's lower-right rim
sm:edge():each(function(x, y)
  local dx, dy = x - SX, y - SY
  if dx > 4 and dy > 2 and dx + dy > 13 and not bm:has(x, y + 1) then c:put(x, y, "#4f8f8a", stok) end end)
-- specular: 2x1 + cream glint upper-left of the shell
c:put(17, 30, SHELL[6], stok) c:put(18, 30, SHELL[6], stok) c:put(17, 29, A.CREAM, stok)

-- quirk: clover leaf on the ground under its mouth, with a bite taken out
local lc = { r = { name = "leaf" } }
local bite = c:ellipse(54.5, 51.2, 1.8, 1.6)
A.leaf(c, 48, 56, 53, 56, 59, 53, 3.0, LEAF, { tok = lc, cut = bite, vs = 3, pw = 0.6 })

A.save(c, "snail-green", "games")
