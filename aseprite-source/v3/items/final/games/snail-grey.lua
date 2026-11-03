-- snail-grey (final pass, Opus single pass). Left-facing, shy: a wide, flattened keeled shell (lens profile with a
-- sharp periphery keel) in cool slate, squashed log-spiral suture, bevelled keel (bright top edge + dark inner groove),
-- stony speckle and growth ribs; only the head and a thin tail peek out, eye stalks half extended. Blue-grey foot
-- with skin furrows, frilled sole, AO + contact shadow under the shell.
-- quirk: a sticking plaster on the shell, patching an old knock.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA0_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local c = A.new("snail-grey")
local BODY = { "#3e4258", "#5f6680", "#8890a8", "#aab3c8", "#c8d0e0", "#e6ecf4" }
local SHELL = { "#2c2c44", "#46475f", "#64657e", "#8a8ca2", "#b3b4c6", "#dcdbe6" }
local btok, stok = { r = { name = "body" } }, { r = { name = "shell" } }

c:groundShadow(32, 56, 22, 1.5)
-- foot: tail lower-right -> head peeking lower-left
local foot = { { 55, 53.5 }, { 42, 55.5 }, { 24, 55.5 }, { 13, 50 } }
local hw = function(t)
  if t < 0.25 then return 0.6 + 2.2 * (t / 0.25) ^ 0.8 end
  return 2.8 + (t - 0.25) * 1.4
end
local head = c:ellipse(11, 49.5, 3.5, 3.5)
local hn = X.sphere(10.2, 48.6, 4, head)
local BCUT = { 0.3, 0.48, 0.64, 0.79, 0.92 }
local bm, bn, BT, BS, bidx = A.foot(c, foot, hw, BODY, { tok = btok, add = { { head, hn, 1 } }, cuts = BCUT, amb = 0.05, wrap = 0.2 })
A.skin(c, bm, bidx, BODY, btok, { s1 = 6, s2 = 7 })
A.sole(c, bm, BODY, 9, 54, btok)
-- lower feelers + mouth
c:put(7, 52, BODY[3], btok) c:put(6, 52, BODY[2], btok)
c:put(8, 51, BODY[1], btok) c:put(9, 52, BODY[2], btok)
c:put(10, 46, BODY[6], btok)

-- shell: lens (two big arcs) joined with an ellipse -> pointed keel at the ends
local SX, SY = 33, 40
local lens = HP.mask()
for y = 20, 60 do for x = 10, 58 do
  local d1 = (x + 0.5 - SX)^2 + (y + 0.5 - (SY + 11.6))^2
  local d2 = (x + 0.5 - SX)^2 + (y + 0.5 - (SY - 11.6))^2
  if d1 <= 21.8^2 and d2 <= 21.8^2 then lens:set(x, y) end
end end
local sm = lens:add(c:ellipse(SX, SY, 14.5, 9.5))
local sidx, sn, ph, sb = A.coil(c, sm, { ramp = SHELL, tok = stok, sx = SX + 1.5, sy = SY - 0.5, aspect = 1.5, a = 1.0, b = 0.2, dir = -1, rot = 2.2,
  cx = SX - 1.5, cy = SY - 2, r = 17, wS = 0.55, R = 5, ribs = 12, ribTwist = 2, amb = 0.16, wrap = 0.42 })
-- keel bevel: bright upper edge, dark groove one px inside along the lower periphery
local ring1 = sm:edge()
local inner = sm:copy():cut(ring1)
local ring2 = inner:edge()
ring1:each(function(x, y) if y < SY - 2 and x < SX + 12 then A.step(c, sidx, SHELL, x, y, 1, stok) end end)
ring2:each(function(x, y) if y > SY + 3 and x > SX - 12 then A.step(c, sidx, SHELL, x, y, -1, stok) end end)
-- stony speckle
sm:each(function(x, y) local k = K(x, y)
  if X.hash(x, y, 7) < 0.05 and (sb[k] or 0) == 0 and sidx[k] and sidx[k] >= 3 then A.step(c, sidx, SHELL, x, y, -1, stok) end
  if X.hash(x, y, 11) < 0.035 and (sb[k] or 0) == 0 and sidx[k] and sidx[k] >= 3 and sidx[k] <= 5 then A.step(c, sidx, SHELL, x, y, 1, stok) end end)
-- aperture lip lower-left where the head comes out
for _, p in ipairs{ { 19, 46 }, { 18, 47 }, { 18, 48 } } do c:put(p[1], p[2], SHELL[6], stok) end
for _, p in ipairs{ { 19, 48 }, { 20, 49 }, { 19, 49 } } do c:put(p[1], p[2], SHELL[1], stok) end
-- AO / contact shadow on the body under the shell
bm:each(function(x, y) if not sm:has(x, y) then
  if sm:has(x, y - 1) then A.step(c, bidx, BODY, x, y, -2, btok)
  elseif sm:has(x, y - 2) then A.step(c, bidx, BODY, x, y, -1, btok) end end end)
-- cool reflected light on the lower-right of the shell
sm:edge():each(function(x, y) if x > SX + 6 and y > SY + 2 and not bm:has(x, y + 1) then c:put(x, y, "#5a7a96", stok) end end)
-- specular streak + glint upper-left
c:put(22, 33, SHELL[6], stok) c:put(23, 33, SHELL[6], stok) c:put(24, 32, SHELL[6], stok) c:put(22, 32, A.CREAM, stok)

-- shy, half-extended eye stalks (in front of the shell rim)
A.stalk(c, 10, 47, 6, 40, BODY, btok, -1)
A.stalk(c, 13, 47, 14, 39, BODY, btok, -1)
-- quirk: sticking plaster across the upper right of the shell (pad + two dotted tabs)
local PL = { a = "#f6d2a8", b = "#e2a878", d = "#b87a5a", p = "#fbe6c6", o = "#c98a64" }
A.map(c, {
  "pa....aa",
  "abaa.aboa",
  ".abbabbo.",
  "..adppo..",
  ".aabbabo.",
  "abbo.abo",
  ".ao...o.",
}, 37, 30, PL, { r = { name = "plaster" } })
A.save(c, "snail-grey", "games")
