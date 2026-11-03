-- ico-mailbox (final, Opus). A rural tunnel mailbox seen side-on: rounded-top painted steel box, a heavier front
-- door flange with a latch knob, the red flag raised on a slim arm, all on a slim wooden post with a cross bracket.
-- Material: per-pixel light (half-cylinder crown over a flat side, 6 sea-blue tones), specular streak along the
-- crown, rolled seam line + rivets, a paint chip showing bare steel, AO under the box and where the bracket meets
-- the post; flag pillow-lit with a pivot bolt; post with grain lines and a pale end grain; 2-tone ground shadow.
-- quirk: a love letter with a red heart seal is poking out from under the door.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA6_4.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, abs, floor, max, min, pi, cos, sin = math.sqrt, math.abs, math.floor, math.max, math.min, math.pi, math.cos, math.sin
local c = A.new("ico-mailbox")
local PB = { "#1d2f56", "#284b80", "#3474aa", "#4f9ccb", "#86c9e2", "#cdf0f2" }
local RD = { "#5e1a30", "#8e2638", "#c33a3c", "#e8573f", "#ff8a5c", "#ffc09a" }
local WD = { "#3e2424", "#5e3a2c", "#864c33", "#a86a40", "#c98f5c", "#e8b982" }
local ST = { "#444663", "#74758c", "#aaa9b8", "#e2e0e6" }
local PAPER = { "#a89a8c", "#d8cbb4", "#f2e6cc", "#fff4d6" }
local SPEC = "#fff8e2"
local tB, tR, tW, tP = { r = { name = "box" } }, { r = { name = "flag" } }, { r = { name = "post" } }, { r = { name = "paper" } }
local BX0, BX1, BY0, BY1, TOPC = 11, 47, 14, 34, 24.5

c:groundShadow(30, 57, 11, 2)

-- post + bracket
local pm = HP.rect(27, 36, 31, 56)
local pn = {}
pm:each(function(x, y) local s = (x + .5 - 29.5) / 3 pn[K(x, y)] = { s, 0, sqrt(1 - s * s) } end)
local pbias = {}
for x = 27, 31 do pbias[K(x, 36)] = -2 pbias[K(x, 37)] = -1 end
local pidx = A.shade(c, pm, pn, WD, { amb = 0.08, wrap = 0.2, bias = pbias, tok = tW })
for y = 40, 54 do if y % 7 ~= 3 then c:put(29, y, WD[3], tW) end if y % 5 ~= 1 and y > 44 then c:put(30, y + 0 , WD[2], tW) end end
c:put(28, 42, WD[6], tW) c:put(28, 43, WD[6], tW)
-- cross bracket plank under the box
local km = HP.rect(19, 35, 40, 37)
local kn = X.pillow(km, 1.4)
local kbias = {}
for x = 19, 40 do kbias[K(x, 35)] = -1 end
local kidx = A.shade(c, km, kn, WD, { amb = 0.1, wrap = 0.25, bias = kbias, tok = tW })
for x = 21, 38 do if x % 6 ~= 0 then c:put(x, 36, WD[4], tW) end end
c:put(19, 36, WD[6], tW) c:put(40, 36, WD[3], tW)   -- end grain stubs
-- nails
c:put(22, 36, ST[1], tW) c:put(37, 36, ST[1], tW)

-- quirk part 1: the letter (painted before the door so the door clamps it)
local lm, LU, LV = A.local_mask(10.5, 20, -1.28, 14, function(u, v) return u >= 0 and u <= 13.5 and v >= -3.4 and v <= 3.4 end)
lm:each(function(x, y) local k = K(x, y)
  local u, v = LU[k], LV[k]
  local col = PAPER[3]
  if v > 2.4 then col = PAPER[4] end
  if v < -2.4 then col = PAPER[2] end
  -- envelope flap fold: a V pointing down from the top corners
  if abs(abs(v) - (13.5 - u) * 0.62) < 0.5 and u > 8 then col = PAPER[1] end
  c:put(x, y, col, tP) end)
-- heart wax seal on the flap tip
do local hx, hy = floor(10.5 + 0.287 * 8.6 + .5) - 1, floor(20 - 0.958 * 8.6 + .5) - 1
  A.map(c, { "R.R", "hRR", ".r." }, hx, hy, { R = RD[3], h = RD[5], r = RD[2] }, tP) end

-- box body
local bm = HP.rrect(BX0, BY0, BX1, BY1, 6)
local bn = {}
bm:each(function(x, y)
  local nx = 0
  if x >= BX1 - 1 then nx = 0.45 * (x - BX1 + 2) end
  if y < TOPC then
    local sn = max(-0.96, (y + .5 - TOPC) / (TOPC - BY0 + 0.6))
    local nz = sqrt(max(0.04, 1 - sn * sn - nx * nx))
    bn[K(x, y)] = { nx, sn, nz }
  else
    local ny = 0.12 + (y - TOPC) / (BY1 - TOPC) * 0.45
    if y >= BY1 - 1 then ny = 0.8 end
    bn[K(x, y)] = { nx, ny, sqrt(max(0.04, 1 - ny * ny - nx * nx)) }
  end
end)
local bbias = {}
local bidx = A.shade(c, bm, bn, PB, { amb = 0.04, wrap = 0.12, cuts = { 0.18, 0.36, 0.55, 0.74, 0.92 }, bias = bbias, tok = tB })
-- rolled seam where the crown meets the flat side: dark line + lit lip above
for x = BX0 + 4, BX1 - 1 do A.step(c, bidx, PB, x, floor(TOPC) + 1, -1, tB) end
-- specular streak along the crown + glint
for x = BX0 + 6, BX1 - 8 do if (x % 9) ~= 4 then c:put(x, BY0 + 3, PB[6], tB) end end
c:put(BX0 + 8, BY0 + 3, SPEC, tB) c:put(BX0 + 9, BY0 + 3, SPEC, tB)
-- rivets along the back seam
for _, y in ipairs{ 19, 25, 31 } do c:put(BX1 - 3, y, PB[6], tB) c:put(BX1 - 3, y + 1, PB[2], tB) end
-- paint chip showing bare steel (lower middle)
A.map(c, { ".gG", "gGs", ".s." }, 36, 28, { g = ST[3], G = ST[4], s = ST[2] }, tB)
-- AO under the box where it sits on the bracket
for x = 18, 41 do if bm:has(x, BY1) then A.step(c, bidx, PB, x, BY1, -1, tB) end end

-- front door flange (heavier, 1 px proud all round)
local dm = HP.rrect(BX0 - 3, BY0 - 1, BX0 + 1, BY1 + 1, 5)
local dn = X.pillow(dm, 1.8)
local didx = A.shade(c, dm, dn, PB, { amb = 0.04, wrap = 0.12, cuts = { 0.2, 0.4, 0.6, 0.8, 0.95 }, tok = tB })
-- door seam (dark) where flange meets the body
for y = BY0 + 1, BY1 - 1 do c:put(BX0 + 1, y, PB[1], tB) end
-- latch knob
A.map(c, { ".hb", "hbb", "bbd", ".dd" }, BX0 - 6, 23, { h = ST[4], b = ST[3], d = ST[1] }, tB)

-- flag arm + flag (raised)
local am = HP.rect(41, 9, 43, 27)
local an = {}
am:each(function(x, y) local s = (x + .5 - 42.5) / 1.8 an[K(x, y)] = { s, 0, sqrt(max(0.05, 1 - s * s)) } end)
A.shade(c, am, an, RD, { amb = 0.08, wrap = 0.2, tok = tR })
local fm = HP.poly{ { 44, 7 }, { 53, 7 }, { 53, 15 }, { 44, 15 } }
local fn = X.pillow(fm, 2)
local fidx = A.shade(c, fm, fn, RD, { amb = 0.08, wrap = 0.25, tok = tR })
-- ambient where flag meets arm
for y = 8, 15 do A.step(c, fidx, RD, 44, y, -1, tR) end
c:put(46, 8, RD[6], tR) c:put(47, 8, RD[6], tR)
-- pivot bolt on the box side
A.map(c, { "hgs", "gss", "sdd" }, 41, 26, { h = ST[4], g = ST[3], s = ST[2], d = ST[1] }, tB)

A.save(c, "ico-mailbox")
