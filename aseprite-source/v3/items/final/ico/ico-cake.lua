-- ico-cake (final, Opus). Whole round layer cake seen a little from above on a china plate: two sponge layers split by
-- a cream filling, glossy pink icing on top running down the side in drips, a slim twisted candle with a lit flame.
-- Material: sponge = cylinder light (6-tone warm crumb) with crumb pores, filling = 3-tone cream with an AO row under
-- the top sponge; icing = 6-tone glossy pink with a specular streak on the top rim and lit drip tips; candle = 2-colour
-- twist; flame = ember/gold/cream teardrop; plate = 6-tone china with a bright rim and a 2-tone ground shadow.
-- quirk: one long drip of icing has run all the way down and pooled on the plate.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA2_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("ico-cake")
local SPONGE = { "#5e3424", "#8a5230", "#b8783e", "#d9a056", "#efc47a", "#fde3a6" }
local CREAMR = { "#b88a7e", "#e6c8b0", "#fff0d6" }
local ICE    = { "#6e2450", "#a83a6e", "#d65a8e", "#f283aa", "#ffb0c8", "#ffdce6" }
local CHINA  = { "#4a4c6a", "#74758c", "#a6a8ba", "#cacbdb", "#e6e6f0", "#f8f6fc" }
local CAND   = { "#3a86b0", "#b6f0e0", "#2a4a7a" }

local CX = 31.5
-- plate + ground shadow
c:groundShadow(32, 52, 19, 2)
local plate = A.ell(CX, 47, 20, 4.6)
local ptok = A.tok("plate")
local pn = X.sphere(CX, 47, 20, plate)
plate:each(function(x, y) local k = K(x, y) local u = (x - CX) / 20.5 local v = (y - 47) / 5
  pn[k] = { A.norm(u * 0.5, v * 1.2 + 0.1, 1) } end)
local pidx = A.shade(c, plate, pn, CHINA, { tok = ptok, amb = 0.12, wrap = 0.3 })
-- plate well (inner ring slightly darker) and bright rim
A.ell(CX, 47, 15, 3.2):edge():each(function(x, y) A.step(c, pidx, CHINA, x, y, -1, ptok) end)
plate:edge():each(function(x, y) if y < 47 and x < CX + 6 then c:put(x, y, CHINA[6], ptok) end end)

-- cake body (solid of revolution)
local H0, H1, TILT, W = 28, 45, 5, 14.6
local side, sn, SI = A.vessel(CX, H0, H1, function() return W end, TILT)
local stok = A.tok("sponge")
local sb = {}
side:each(function(x, y) local k = K(x, y) local h = SI[k].h
  if h > H1 - 1.5 then sb[k] = -1 end end)
-- AO onto the plate where the cake stands
side:grow(1):cut(side):each(function(x, y) if plate:has(x, y) and y >= 46 then A.step(c, pidx, CHINA, x, y, -2, ptok) end end)
local sidx = A.shade(c, side, sn, SPONGE, { tok = stok, bias = sb, amb = 0.1, wrap = 0.25, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 } })
-- cream filling band + AO row beneath the upper sponge
local ctok = A.tok("filling")
side:each(function(x, y) local k = K(x, y) local h, u = SI[k].h, SI[k].u
  if h >= 36 and h < 38.2 then
    local t = (u < -0.3) and 3 or ((u < 0.55) and 2 or 1)
    if h >= 37.4 then t = max(1, t - 1) end
    c:put(x, y, CREAMR[t], ctok)
  elseif h >= 38.2 and h < 39.2 then A.step(c, sidx, SPONGE, x, y, -1, stok) end
end)
-- crumb pores
side:each(function(x, y) local k = K(x, y) local h = SI[k].h
  if (h < 36 or h >= 39.2) and X.hash(x, y, 7) > 0.86 and abs(SI[k].u) < 0.9 then A.step(c, sidx, SPONGE, x, y, -1, stok)
    if side:has(x - 1, y - 1) and X.hash(x, y, 9) > 0.5 then A.step(c, sidx, SPONGE, x - 1, y - 1, 1, stok) end end end)

-- icing: top ellipse + rim band + drips down the side
local itok = A.tok("icing")
local top = A.ell(CX, H0, W + 0.3, TILT)
local drip = {}
local long = 40                                  -- quirk drip column (front right)
for x = floor(CX - W), floor(CX + W) do
  local L = 1 + floor(X.hash(x // 3, 1, 3) * 5)
  if (x // 3) % 2 == 0 then L = max(1, L - 2) end
  if x == long or x == long + 1 then L = 30 end
  drip[x] = L
end
local icing = top:copy()
local ii = {}
side:each(function(x, y) local k = K(x, y) local h = SI[k].h
  if h < H0 + 2.2 + (drip[x] or 0) then icing:set(x, y) ii[k] = h end end)
-- puddle at the foot of the long drip
local pud = A.ell(long + 1.5, 47.6, 3.2, 1.2)
pud:cut(side)
icing:add(pud)
local inn = {}
icing:each(function(x, y) local k = K(x, y)
  if top:has(x, y) then local u, v = (x - CX) / (W + 0.8), (y - H0) / (TILT + 0.6)
    inn[k] = { A.norm(u * 0.35, v * 0.4 - 0.55, 1) }
  elseif pud:has(x, y) then inn[k] = { A.norm((x - long - 1.5) * 0.15, -0.6, 1) }
  else inn[k] = sn[k] or { 0, 0, 1 } end end)
local ib = {}
icing:each(function(x, y) local k = K(x, y)
  if ii[k] and not icing:has(x, y + 1) then ib[k] = 1 end end)  -- drip tips catch light
local iidx = A.shade(c, icing, inn, ICE, { tok = itok, bias = ib, amb = 0.1, wrap = 0.25, cuts = { 0.24, 0.42, 0.6, 0.76, 0.9 } })
-- rim crest: the front edge of the top surface is a rounded lip (dark under, lit on it)
top:each(function(x, y) if not top:has(x, y + 1) then
  A.step(c, iidx, ICE, x, y, (x < CX + 4) and 1 or 0, itok)
  if icing:has(x, y + 1) then A.step(c, iidx, ICE, x, y + 1, -1, itok) end end end)
-- specular streak on the glossy rim, upper left
for _, p in ipairs{ { 21, 26 }, { 22, 25 }, { 23, 25 }, { 24, 24 } } do c:put(p[1], p[2], ICE[6], itok) end
c:put(19, 32, ICE[6], itok)
-- sprinkles on top
for _, s in ipairs{ { 24, 29, "#ffe38a" }, { 38, 30, "#b6f0e0" }, { 27, 31, "#c9b2f0" }, { 41, 27, "#ffe38a" }, { 20, 28, "#b6f0e0" } } do
  c:put(s[1], s[2], s[3], itok) c:put(s[1] + 1, s[2], s[3], itok) end

-- candle: slim twisted stick standing in the icing
local ktok = A.tok("candle")
for y = 14, 27 do for x = 30, 32 do
  local st = ((x + y) // 2) % 2 == 0
  local col = st and CAND[1] or CAND[2]
  if x == 32 then col = st and CAND[3] or "#8bc4ea" end
  c:put(x, y, col, ktok)
end end
c:put(30, 27, ICE[2], itok) c:put(31, 28, ICE[2], itok) c:put(32, 27, ICE[2], itok)   -- icing collar shadow
-- wick + flame teardrop
c:put(31, 13, A.INK, ktok)
A.map(c, {
  "..o..",
  ".oo..",
  ".ogo.",
  "oggo.",
  "ogcgo",
  "ogcgo",
  ".ogo.",
}, 29, 6, { o = "#e8493b", g = "#f5b82e", c = A.CREAM }, A.tok("flame"))
A.save(c, "ico-cake")
