-- ico-medal-silver (Opus single pass, replaces the Sonnet draft). Second place as a round coin on a V ribbon:
-- two slim sea-blue straps with cream edge stripes and twill weave cross into a bail (the right strap lies over the
-- left, which takes a dark ambient row and contact shadow); the silver coin has a pillow-bevelled rim with a bright
-- specular arc, a recessed polished field (dark wall upper-left, lit lip lower-right) and a raised 2.
-- quirk: a loose thread has come unpicked from the left strap and dangles beside it.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA6_5.lua")
local HP, X, K = A.HP, A.X, A.K
local c = A.new("ico-medal-silver")
local S = A.SILV
local BLU = { "#22385e", "#2c5a8a", "#3a7eb4", "#56a2cc", "#80c4dc", "#b4e6ee" }
local CRM = { "#8a8494", "#b6aeb6", "#d8d0c8", "#eee4d0", "#f8eedc", "#fff4d6" }
local tl, trr, tm = A.tok("strapL"), A.tok("strapR"), A.tok("silver")

local function strap(pts, ax, ay, bx, by, tok, edgeSide)
  local m = c:poly(pts)
  local idx, Ss = A.strap(c, m, ax, ay, bx, by, 4.2, BLU, tok, { tp = 4, tw = -1 })
  -- cream edge stripe one pixel in from the outer edge
  m:each(function(x, y) local s = Ss[K(x, y)]
    if s * edgeSide > 0.5 and s * edgeSide < 0.78 then c:put(x, y, s < 0 and CRM[5] or CRM[3], tok) end end)
  return m
end
local L = strap({ { 13, 6 }, { 23, 6 }, { 36, 24 }, { 29, 27 } }, 18, 6, 32.5, 25.5, tl, -1)
-- right strap over the left: contact shadow on the left strap first
local Rpts = { { 41, 6 }, { 51, 6 }, { 35, 27 }, { 28, 24 } }
local Rm = c:poly(Rpts)
Rm:shift(-1, 1):cut(Rm):each(function(x, y) if L:has(x, y) then c:put(x, y, BLU[1], tl) end end)
strap(Rpts, 46, 6, 31.5, 25.5, trr, 1)
-- ambient rows at the top cut edge (strap folds over the hanger)
for x = 13, 51 do if c:get(x, 6) then c:put(x, 6, BLU[2], x < 32 and tl or trr) end end

-- bail: a round loop through which the straps run
local bail = c:ellipse(32, 26, 3, 2.5):cut(c:ellipse(32, 26, 1, 0.6))
A.shade(c, bail, X.sphere(31.5, 25.5, 3, bail), S, { tok = tm })
c:put(32, 26, BLU[1], tl)
-- neck nub joining bail to coin
local nub = HP.rect(30, 28, 34, 29)
A.bar(c, 30, 28.5, 34, 28.5, 1.2, S, tm)

-- coin
local CX, CY, R = 32, 43, 14
local coin = c:ellipse(CX, CY, R, R)
local cn = X.pillow(coin, 3.3)
A.shade(c, coin, cn, S, { tok = tm, cuts = { 0.24, 0.42, 0.58, 0.72, 0.86 } })
local field = c:ellipse(CX, CY, R - 4, R - 4)
A.field(c, field, S, tm, { mid = 4 })
-- polished field: a soft diagonal sheen band
field:each(function(x, y) local g = (x - CX) - (y - CY)
  if (g == -6 or g == -7) and field:shrink(1):has(x, y) then c:put(x, y, S[5], tm) end end)
local dg = A.digit(2, 28, 37)
A.emboss(c, dg, S, tm, field, { R = 1.3 })
-- rim specular arc + glint
for _, p in ipairs{ { -11, -5 }, { -11, -6 }, { -10, -7 }, { -9, -8 }, { -8, -9 }, { -10, -6 } } do c:put(CX + p[1], CY + p[2], S[6], tm) end
c:put(CX - 10, CY - 7, A.CREAM, tm)
-- cool reflected light on the lower-right rim
local rim = X.rim(cn)
coin:edge():each(function(x, y) if rim[K(x, y)] > 0.45 and x > CX + 3 and y > CY + 3 then c:put(x, y, "#7a7fb8", tm) end end)

-- quirk: loose thread dangling from the left strap's outer edge
local th = A.tok("thread")
for _, p in ipairs{ { 16, 11 }, { 15, 12 }, { 14, 13 }, { 14, 14 }, { 13, 15 }, { 13, 16 }, { 14, 17 } } do
  c:put(p[1] - 1, p[2], (p[2] % 2 == 0) and CRM[4] or CRM[2], th)
end
A.save(c, "ico-medal-silver")
