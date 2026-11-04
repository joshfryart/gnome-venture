-- carnation-seed (final, Opus single pass). A torn piece of a narrow glaucous carnation leaf runs up to the right
-- (blue-grey green, waxy bloom flecks, sunken midrib groove with lit lip, natural pointed tip, torn base, cool rim).
-- Three flat black shield-shaped carnation seeds with a dished centre, pebbly coat and a hilum notch sit on it (AO +
-- contact shadow). The left seed has sprouted: pale stem, two oblong cotyledons, then the first opposite pair of
-- narrow grey-green carnation leaves arching up in a V.
-- quirk: one pink, pinked-edge carnation petal has drifted onto the leaf tip.
local NAME = "carnation-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r0_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sin, pi, atan = math.floor, math.max, math.min, math.abs, math.sin, math.pi, math.atan
local c = A.new(NAME)

local GL = { "#1a3436", "#26504f", "#3a7068", "#5a9286", "#86b6a2", "#bcd8c4" }
local BLOOM = "#d8ead8"
local COOL = "#3c5e7a"
local SD = { "#18121a", "#261c2c", "#382c40", "#4e405a", "#6e6080", "#a294b8" }
local STEM = { "#4c7e5a", "#7aa680", "#a8ccaa", "#d6ecd0" }
local PET = { "#7d2c5e", "#c94f84", "#f5809f", "#ffb0c8", "#ffd8e4" }

-- leaf scrap: lower-left torn base to a pointed tip upper-right
local lw = 5.6
local lm, ln, LT, LS, len = A.blade(7, 55, 30, 52, 57, 33, function(t)
  if t > 0.99 then return -1 end
  return max(0.5, lw * (1 - t ^ 3.2))
end, { fold = 0.42 })
A.tear(lm, LT, LS, len, lw, 0, 4, 21)

-- seeds {cx, cy, rx, ry, ang}
local S = { { 17, 51, 2.6, 2.2, 0.3 }, { 28, 49, 2.6, 2.1, -0.4 }, { 37, 45, 2.5, 2.1, 0.1 } }
for _, s in ipairs(S) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.6) end

-- petal on the tip area
local pm, pn, PU, PV, pg = A.pod(44, 41, 54, 32, 3.4, 0.55)

-- sprout from seed 1
local stm, stn, STT, STS = A.tube({ { 17, 49 }, { 18, 41 }, { 16, 33 }, { 17, 22 } }, function(t) return 1.05 end)
local function blade(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S2 = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.6)
  end, { fold = 0.35 })
  return { m = m, n = n, T = T, S = S2 }
end
local cots = { blade(16, 33, 12, 32, 8, 30, 1.9), blade(18, 33, 22, 32, 26, 30, 1.9) }
local tl = { blade(16, 23, 11, 17, 8, 9, 1.6), blade(18, 23, 24, 17, 27, 9, 1.6) }

-- leaf scrap
local lbias = {}
for _, s in ipairs(S) do X.ao(lbias, lm, s.m, 1, -1) A.cast(lbias, lm, s.m, 1, 1, -1) end
X.ao(lbias, lm, pm, 1, -1) A.cast(lbias, lm, pm, 1, 1, -1)
A.cast(lbias, lm, stm, 1, 1, -1)
local ltok = A.tok("leaf")
local lvis = lm:copy():cut(pm):cut(stm)
for _, s in ipairs(S) do lvis:cut(s.m) end
local lidx = A.shade(c, lvis, ln, GL, { bias = lbias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.16, wrap = 0.3 })
lvis:each(function(x, y) local k = K(x, y)
  if lbias[k] then return end
  local s = LS[k]
  if abs(s) < 0.1 and LT[k] < 0.92 then c:put(x, y, GL[2], ltok)                      -- sunken midrib groove
  elseif s < -0.1 and s > -0.28 and LT[k] < 0.9 then c:put(x, y, GL[6], ltok)          -- lit lip of the groove
  elseif s < -0.3 and X.hash(x, y, 8) > 0.85 and (lidx[k] or 0) >= 4 then c:put(x, y, BLOOM, ltok) -- waxy bloom
  elseif s > 0.3 and X.hash(x, y, 9) > 0.88 then c:put(x, y, GL[max(1, (lidx[k] or 3) + 1)], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if lvis:has(x, y) and not lbias[k] and LS[k] > 0.7 and LT[k] < 0.85 then c:put(x, y, COOL, ltok) end end)

-- sprout: stem, cotyledons, first true leaves
local stok = A.tok("sprout")
local stv = stm:copy()
A.shade(c, stv, stn, STEM, { tok = stok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })
for i, b in ipairs(cots) do
  local v = b.m:copy():cut(stm)
  local bias = {} X.ao(bias, b.m, stm, 1, -1)
  local idx = A.shade(c, v, b.n, GL, { tok = stok, bias = bias, amb = 0.2, wrap = 0.3 })
  v:each(function(x, y) local k = K(x, y) if abs(b.S[k]) < 0.15 and b.T[k] > 0.15 and b.T[k] < 0.8 then c:put(x, y, GL[min(6, (idx[k] or 3) + 1)], stok) end end)
end
for i, b in ipairs(tl) do
  local v = b.m:copy():cut(stm)
  local bias = {} X.ao(bias, b.m, stm, 1, -1)
  local idx = A.shade(c, v, b.n, GL, { tok = stok, bias = bias, amb = 0.18, wrap = 0.3 })
  v:each(function(x, y) local k = K(x, y)
    if abs(b.S[k]) < 0.15 and b.T[k] > 0.1 and b.T[k] < 0.85 then c:put(x, y, b.S[k] <= 0 and GL[6] or GL[3], stok)
    elseif b.S[k] < -0.4 and X.hash(x, y, 12 + i) > 0.8 and (idx[k] or 0) >= 4 then c:put(x, y, BLOOM, stok) end end)
end
-- node collar at the top pair
for _, q in ipairs{ { 17, 23 }, { 16, 23 } } do if stm:has(q[1], q[2]) then c:put(q[1], q[2], STEM[1], stok) end end

-- petal: pinked (zig-zag) outer edge, pale claw at the base, vein lines
local ptok = A.tok("petal")
local pcut = {}
pm:each(function(x, y) local k = K(x, y)
  if PU[k] > 0.55 and ((x + y) % 2 == 0) and pm:edge():has(x, y) then pcut[#pcut + 1] = k end end)
for _, k in ipairs(pcut) do pm.s[k] = nil end
local pidx = A.shade(c, pm, pn, PET, { tok = ptok, cuts = { 0.2, 0.4, 0.62, 0.82 }, amb = 0.25, wrap = 0.4 })
pm:each(function(x, y) local k = K(x, y)
  if PU[k] and PU[k] < -0.6 then c:put(x, y, PET[5], ptok)
  elseif PV[k] and abs(PV[k]) < 0.12 and PU[k] > -0.5 and PU[k] < 0.6 then c:put(x, y, PET[2], ptok) end end)

-- seeds last
for i, s in ipairs(S) do
  local tok = A.tok("seed" .. i)
  local vis = s.m:copy()
  local cx, cy = s[1], s[2]
  local idx = {}
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - cx, y - cy
    local r = math.sqrt((dx / (s[3] + 0.45))^2 + (dy / (s[4] + 0.45))^2)
    local i2
    if r > 0.62 then i2 = (dx + dy < -0.5) and 5 or ((dx + dy > 1.5) and 2 or 3)   -- raised rim
    else i2 = (dx + dy < 0) and 2 or 4 end                                      -- dished centre (lit on far wall)
    if X.hash(x, y, 30 + i) > 0.8 and i2 >= 2 and i2 <= 4 then i2 = i2 + 1 end -- pebbly tubercles
    idx[k] = i2 c:put(x, y, SD[i2], tok)
  end)
  -- hilum notch on the right side
  local hx, hy = floor(cx + s[3] + 0.3), floor(cy + 0.5)
  if vis:has(hx, hy) then c:put(hx, hy, SD[1], tok) end
  -- glint
  local gx, gy = floor(cx - s[3] * 0.5), floor(cy - s[4] * 0.6)
  if vis:has(gx, gy) then c:put(gx, gy, SD[6], tok) end
end
-- seed 1 coat split where the shoot leaves
for _, q in ipairs{ { 17, 49 }, { 18, 49 } } do c:put(q[1], q[2], STEM[3], stok) end

A.save(c, NAME)
