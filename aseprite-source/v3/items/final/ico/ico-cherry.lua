-- ico-cherry (final, Opus). A pair of glossy dark-red cherries hanging from two slim curved stems that meet at a woody
-- nub, one pointed leaf flaring out to the right.
-- Material: cherries = analytic sphere light snapped to 6 reds, waxy bloom (pale lit cap), one bright specular + cream
-- glint each, cool violet reflected light on the lower-right rim, dark stem dimple; stems = 3-tone with a lit side;
-- nub = wood with a pale cut end; leaf = 6-tone V-fold blade with midrib and veins, AO where it joins the nub.
-- quirk: somebody already took a bite out of the right cherry: pale juicy flesh, the pit peeking out, one juice drop.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA2_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local c = A.new("ico-cherry")
local RED  = { "#3e0f26", "#6a1530", "#9c1c34", "#c92a3a", "#e8503f", "#ff8a6a" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local STEM = { "#3d5a2c", "#6f8f3a", "#a8c060" }
local WOOD = { "#51302b", "#864c33", "#b97a4a", "#e8b982" }
local FLESH = { "#a8243c", "#e0566a", "#ff98a0" }
local PIT = { "#a87850", "#e8c49a" }
local SPEC, BOUNCE = "#fff4d6", "#8a5ca8"

local JX, JY = 33, 11   -- where the stems meet
local cher = { { cx = 20.5, cy = 43.5, r = 9.2 }, { cx = 42.5, cy = 46, r = 9.2 } }

-- leaf (behind everything)
local lm, ln, LT, LS = A.blade(JX + 1, JY, 47, 3, 58, 18, function(t) return 5.2 * math.sin(math.pi * math.min(1, t * 1.05)) ^ 0.8 - 0.2 end, { fold = 0.5 })
local ltok = A.tok("leaf")
local lbias = {}
lm:each(function(x, y) local k = K(x, y) if LT[k] < 0.12 then lbias[k] = -1 end end)
local lidx = A.shade(c, lm, ln, LEAF, { tok = ltok, bias = lbias, amb = 0.1, wrap = 0.3 })
-- midrib + veins
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  if abs(s) < 0.16 and t > 0.06 and t < 0.92 then c:put(x, y, s < 0 and LEAF[6] or LEAF[3], ltok) end
end)
for _, vt in ipairs{ 0.32, 0.52, 0.72 } do
  lm:each(function(x, y) local k = K(x, y)
    local t, s = LT[k], LS[k]
    local want = vt + abs(s) * 0.12
    if abs(t - want) < 0.022 and abs(s) > 0.2 and abs(s) < 0.8 then c:put(x, y, LEAF[(lidx[k] or 3) > 3 and 3 or 2], ltok) end
  end)
end

-- stems: thin curved tubes from the nub into each cherry top
local stok = A.tok("stem")
local function stem(p)
  local m, n = A.tube(p, function(t) return 0.95 + t * 0.25 end)
  local v = X.light(n, { amb = 0.1, wrap = 0.3 })
  X.tone(c, m, v, STEM, { cuts = { 0.35, 0.7 }, tok = stok })
  return m
end
local s1 = stem({ { JX - 1, JY + 1 }, { 26, 16 }, { 21, 26 }, { 20.5, 35 } })
local s2 = stem({ { JX + 0, JY + 1 }, { 39, 18 }, { 42, 27 }, { 42.5, 37.5 } })

-- woody nub at the join, pale cut end on top
local nub = c:rect(JX - 2, JY - 2, JX + 1, JY + 1)
local wtok = A.tok("nub")
nub:each(function(x, y) c:put(x, y, (x >= JX) and WOOD[2] or WOOD[3], wtok) end)
c:put(JX - 2, JY - 2, WOOD[4], wtok) c:put(JX - 1, JY - 2, WOOD[4], wtok) c:put(JX, JY - 2, WOOD[3], wtok)
c:put(JX + 1, JY - 2, WOOD[2], wtok) c:put(JX + 1, JY + 1, WOOD[1], wtok) c:put(JX, JY + 1, WOOD[1], wtok)
c:put(JX - 1, JY, WOOD[2], wtok) -- grain fleck

-- cherries
local bite = A.ell(47.5, 40.5, 4.0, 3.8):add(A.ell(44.2, 37.6, 2.2, 2.0)):add(A.ell(50.6, 44.6, 2.2, 2.4))
for i, ch in ipairs(cher) do
  local m = A.ell(ch.cx, ch.cy, ch.r, ch.r - 0.4)
  -- slight heart dip at the top where the stem goes in
  m:cut(c:rect(floor(ch.cx) - 1, floor(ch.cy - ch.r) - 1, floor(ch.cx) + 1, floor(ch.cy - ch.r)))
  if i == 2 then m:cut(bite) end
  -- clear the stems where the cherry sits on them
  local tok = A.tok("cherry" .. i)
  local n = X.sphere(ch.cx, ch.cy, ch.r, m)
  local bias = {}
  if i == 2 then X.ao(bias, m, bite, 1, -1) end
  local idx = A.shade(c, m, n, RED, { tok = tok, bias = bias, amb = 0.05, wrap = 0.2, cuts = { 0.3, 0.46, 0.62, 0.78, 0.92 } })
  -- waxy bloom: pale band on the lit upper-left shoulder
  local sp = X.spec(n, 6)
  m:each(function(x, y) local k = K(x, y) if sp[k] > 0.8 and (idx[k] or 1) >= 4 then c:put(x, y, RED[6], tok) end end)
  -- specular: 2x2 hard highlight + cream glint
  local hx, hy = floor(ch.cx - ch.r * 0.45 + .5), floor(ch.cy - ch.r * 0.45 + .5)
  c:put(hx, hy, SPEC, tok) c:put(hx + 1, hy, "#ffd0b0", tok) c:put(hx, hy + 1, "#ffd0b0", tok)
  -- cool reflected light lower-right rim
  local rim = X.rim(n)
  m:edge():each(function(x, y) local k = K(x, y)
    if rim[k] > 0.7 and not bite:grow(1):has(x, y) then c:put(x, y, BOUNCE, tok) end end)
  -- stem dimple
  local tx, ty = floor(ch.cx), floor(ch.cy - ch.r) + 1
  c:put(tx - 1, ty, RED[1], tok) c:put(tx, ty, RED[2], tok) c:put(tx + 1, ty, RED[1], tok)
  c:put(tx, ty + 1, RED[3], tok)
end

-- bite: pale juicy flesh band inside the scallop, darker red where it meets the skin, pit peeking out
local ftok = A.tok("flesh")
local body2 = A.ell(42.5, 46, 9.2, 8.8)
local g1, g2, g3 = bite:grow(1), bite:grow(2), bite:grow(3)
body2:each(function(x, y)
  if bite:has(x, y) then return end
  if g2:has(x, y) then
    local lit = (x - 47) + (y - 41) > 0     -- far wall of the hollow catches the light
    c:put(x, y, (g1:has(x, y) and lit) and FLESH[3] or FLESH[2], ftok)
  elseif g3:has(x, y) then c:put(x, y, FLESH[1], ftok) end
end)
-- pit in the bottom of the hollow
A.map(c, { ".hp", "hpp", "pP." }, 43, 41, { h = "#fff0d0", p = PIT[2], P = PIT[1] }, ftok)
-- juice drop under the bite
c:put(53, 51, FLESH[3], ftok) c:put(53, 52, FLESH[2], ftok) c:put(54, 52, FLESH[2], ftok) c:put(53, 53, FLESH[1], ftok) c:put(54, 53, FLESH[1], ftok)
A.save(c, "ico-cherry")
