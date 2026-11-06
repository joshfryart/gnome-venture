-- pickled-eggs (C34, Opus single pass). Round-bellied glass globe jar with a short neck, a tapered cork stopper (pores,
-- pale top) and a twisted twine tie with a loose tail; beet-pink brine; peeled eggs (per-pixel sphere light, white core
-- blushing to beet pink at the rims), two peppercorns, glass lit band + cool bounce, AO where the eggs touch.
-- quirk: one small speckled quail egg, still in its shell, has sneaked in among the hen eggs.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC34_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new("pickled-eggs")
local CX = 32
c:groundShadow(CX, 53, 12, 2)

local BRINE = { "#5e1c48", "#8e2c62", "#c04a84", "#e070a0", "#f49cbc", "#ffd0de" }
local EGG = { "#8a5a78", "#c08aa0", "#e6bcc8", "#f8dedc", "#fff1ea", "#fffaf5" }
local BLUSH = { "#5e1a48", "#9a336c", "#cc5a8a", "#ea84a8", "#f6aec4", "#ffd2de" }
local QUAIL = { "#6a5048", "#9c8068", "#c8b08c", "#e4d2ae", "#f4e8cc", "#fffaea" }
local CORK = { "#4a2e24", "#7a4a30", "#a8703f", "#c99a5e", "#e0bd82", "#f4dca8" }
local TW = { "#6e4a2e", "#b08a5a", "#e2c48e" }

local function hw(y)
  if y < 17 or y > 51 then return nil end
  if y <= 18 then return 7.6 end
  if y <= 22 then return 6.4 end
  if y == 51 then return 7.0 end
  local g = 225 - (y - 37) ^ 2
  return max(6.4, g > 0 and sqrt(g) or 0)
end
local body, bn, NX = A.lathe(CX, 17, 51, hw)
local inner = body:shrink(1)
-- keep the neck interior narrow (glass wall 1px)
local LEVEL = 27
local tok = { r = { name = "contents" } }
local liq = HP.mask()
inner:each(function(x, y)
  if y < LEVEL then c:put(x, y, (NX[K(x, y)] or 0) < -.2 and "#eef9fc" or "#d6edf5", tok)
  else liq:set(x, y) end end)
local ln = {} liq:each(function(x, y) ln[K(x, y)] = bn[K(x, y)] end)
A.tone(c, liq, ln, BRINE, { amb = .3, wrap = .45, tok = tok })
for x = CX - 15, CX + 15 do if liq:has(x, LEVEL) then c:put(x, LEVEL, x < CX + 5 and BRINE[6] or BRINE[5], tok) end end

local occ = HP.mask()
local function egg(ex, ey, ux, uy, ra, rb, ramp, rim)
  local l = sqrt(ux*ux + uy*uy) ux, uy = ux / l, uy / l
  local m = A.rell(ex, ey, ux, uy, ra, rb)
  m:clip(inner)
  local n = {}
  m:each(function(x, y)
    local dx, dy = x + .5 - ex, y + .5 - ey
    local a, b = (dx * ux + dy * uy) / (ra + .4), (-dx * uy + dy * ux) / (rb + .4)
    local q = max(.03, 1 - a*a - b*b)
    -- back to image space: normal xy follows the ellipse gradient
    local gx = a / (ra + .4) * ux - b / (rb + .4) * uy
    local gy = a / (ra + .4) * uy + b / (rb + .4) * ux
    local s = sqrt(gx*gx + gy*gy) + 1e-6
    local r = sqrt(1 - q)
    n[K(x, y)] = { A.norm(gx / s * r, gy / s * r, sqrt(q)) }
  end)
  local bias = {}
  -- AO where it sits against earlier eggs
  X.ao(bias, m, occ, 1, -1)
  local idx = A.tone(c, m, n, ramp, { amb = .12, wrap = .3, tok = tok, bias = bias })
  if rim then
    -- beet blush soaks in from the outside: rim pixels take the pink ramp at the same tone
    m:each(function(x, y) local k = K(x, y) if n[k][3] < .62 then c:put(x, y, rim[idx[k]], tok) end end)
  end
  -- separation line on top of earlier eggs
  m:edge():each(function(x, y)
    if occ:has(x + 1, y) or occ:has(x - 1, y) or occ:has(x, y + 1) or occ:has(x, y - 1) then
      if not occ:has(x, y) then c:put(x, y, (rim or ramp)[1], tok) end end end)
  -- contact shadow cast down-right onto what is behind
  local sh = m:shift(1, 1):cut(m)
  sh:each(function(x, y) if occ:has(x, y) then local h = c:get(x, y) if h then c:put(x, y, A.mix(h, "#4a1a3a", .35), tok) end end end)
  occ:add(m)
  return m, n, idx
end
egg(26.5, 35, .25, 1, 7.2, 5.3, EGG, BLUSH)
egg(37.8, 34.5, -.2, 1, 7.0, 5.2, EGG, BLUSH)
egg(30.5, 45, 1, .12, 7.2, 5.4, EGG, BLUSH)
-- quirk: speckled quail egg, still in its shell
local qm, qn, qi = egg(40.5, 45.5, .3, 1, 4.1, 3.2, QUAIL)
qm:each(function(x, y) local h = X.hash(x, y, 31)
  if h > .72 then c:put(x, y, h > .9 and "#3c2a2a" or "#6a4a3a", tok) end end)
-- peppercorns
for _, p in ipairs{ { 23, 47 }, { 36, 50 } } do
  c:put(p[1], p[2], "#3a1e24", tok) c:put(p[1] + 1, p[2], "#2e1820", tok)
  c:put(p[1], p[2] - 1, "#6a3a3a", tok) c:put(p[1] + 1, p[2] - 1, "#4a2a2e", tok)
end
-- egg specular (one each, on the big eggs)
c:put(24, 31, A.SPEC, tok) c:put(35, 30, A.SPEC, tok) c:put(26, 42, A.SPEC, tok)
-- submerged tint
occ:each(function(x, y) if y > LEVEL then local h = c:get(x, y) if h then c.pix[y * c.w + x] = A.mix(h, "#e070a0", .1) end end end)
-- bubbles
for _, b in ipairs{ { 33, 29 }, { 34, 31 }, { 44, 39 } } do c:put(b[1], b[2], "#ffe8f0", tok) end

A.glass(c, body, inner, bn, NX, { ys = LEVEL + 1 })
-- lip: thick rolled rim rows 17..18
for x = CX - 8, CX + 8 do
  if body:has(x, 17) then c:put(x, 17, x < CX - 2 and A.GLASS[6] or A.GLASS[4]) end
  if body:has(x, 18) then c:put(x, 18, x < CX - 2 and A.GLASS[4] or A.GLASS[2]) end
end

-- cork: tapered stopper standing proud of the lip
local cm, cn = A.lathe(CX, 9, 17, function(y) if y == 9 then return 4.6 end return 5.6 - (y - 10) * .12 end, 1.2)
local ci = A.tone(c, cm, cn, CORK, { amb = .15, wrap = .3 })
cm:each(function(x, y) local h = X.hash(x, y, 11) local k = K(x, y)
  if y > 9 and h > .78 then c:put(x, y, CORK[max(1, ci[k] - (h > .92 and 2 or 1))]) end end)
for x = CX - 4, CX + 3 do c:put(x, 9, x < CX and CORK[6] or CORK[5]) end
for x = CX - 5, CX + 5 do if cm:has(x, 16) then c:put(x, 16, CORK[2]) end if cm:has(x, 17) then c:put(x, 17, CORK[1]) end end
-- twine twisted round the neck (rows 20-21), alternating diagonal strands, tail hanging right
for x = CX - 7, CX + 6 do
  local ph = (x + 40) % 3
  c:put(x, 20, ph == 0 and TW[3] or (ph == 1 and TW[2] or TW[1]))
  c:put(x, 21, ph == 2 and TW[3] or (ph == 0 and TW[2] or TW[1]))
end
for x = CX - 7, CX + 6 do if x > CX + 2 then
  local h = c:get(x, 20) if h == TW[3] then c:put(x, 20, TW[2]) end end end
-- knot + tail
c:put(CX + 7, 20, TW[2]) c:put(CX + 7, 21, TW[1]) c:put(CX + 8, 21, TW[2])
A.ln(c, CX + 8, 22, CX + 10, 25, TW[2]) A.ln(c, CX + 9, 22, CX + 11, 24, TW[3])
c:put(CX + 10, 26, TW[1]) c:put(CX + 11, 25, TW[2])

A.fin(c, "pickled-eggs")
