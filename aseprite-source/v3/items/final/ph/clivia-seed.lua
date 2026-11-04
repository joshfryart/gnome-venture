-- clivia-seed (final, Opus single pass). Three plump pearly clivia seeds (cream-pink, slightly angular, a waxy
-- bloom with one bright specular each, cool reflected light) lying on a torn scrap of clivia strap leaf: long,
-- glossy dark green, channelled along the middle, fine parallel veins, both ends ripped with pale torn tissue, AO
-- and contact shadows under the seeds. The right seed has germinated: pale radicle curling over the leaf edge and a
-- pink-white sheath with two arching strap leaves (the clivia leaf shape).
-- quirk: the left seed still wears a shred of its red berry skin.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB20_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sin, cos, pi, sqrt = math.floor, math.abs, math.max, math.min, math.sin, math.cos, math.pi, math.sqrt
local NAME = "clivia-seed"
local c = A.new(NAME)
local LEAF  = { "#122f2c", "#1a4834", "#25623d", "#357f45", "#55a04f", "#8cc462" }
local VEIN, TORN, COOL = "#4a9450", "#c8e09a", "#2f5f6a"
local SEED  = { "#5c2e3e", "#8e4e5a", "#c27f7c", "#e4ae9c", "#f6d4bc", "#fff0dc" }
local SBNC  = "#9fb2c4"
local RED   = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
local ROOT  = { "#8a6a5a", "#c8a88e", "#ecd8bc" }
local SHEATH = { "#8a4a62", "#c97a90", "#f0c0c8" }

-- leaf scrap: strap on a shallow diagonal, constant width, both ends torn
local ltok = A.tok("leaf")
local lm, ln, LT, LS, len = A.blade(7, 50, 30, 50, 57, 41, function(t) return 4.6 - t * 0.6 end, { fold = 0.4 })
local tornE = A.tear(lm, function(x, y) local k = K(x, y) return LT[k] and (LT[k] < 0.045 or LT[k] > 0.955) end, 3, true)
-- seeds
local seeds = {
  { 18, 45, 4.6, 3.7, -0.3 },
  { 29, 44, 5.0, 4.0, 0.25 },
  { 41, 41, 4.6, 3.9, -0.5 },
}
for _, s in ipairs(seeds) do s.m, s.n = A.ell(s[1], s[2], s[3], s[4], s[5]) end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local lidx = A.shade(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.15, wrap = 0.3 })
-- parallel veins + central channel (strap leaves have no proud midrib)
lm:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local s = LS[k]
  if abs(s) < 0.1 then c:put(x, y, LEAF[2], ltok)
  elseif abs(s + 0.12) < 0.07 then c:put(x, y, LEAF[min(6, (lidx[k] or 3) + 1)], ltok)
  elseif (abs(abs(s) - 0.5) < 0.06 or abs(abs(s) - 0.78) < 0.05) and X.hash(x, y, 9) < 0.8 then
    c:put(x, y, (s < 0) and VEIN or LEAF[max(1, (lidx[k] or 3) - 1)], ltok) end
end)
-- glossy leaf: specular streak along the lit half
local spx = { { 10, 46 }, { 11, 46 }, { 12, 46 }, { 47, 38 }, { 48, 38 }, { 49, 37 } }
for _, p in ipairs(spx) do if lm:has(p[1], p[2]) and not bias[K(p[1], p[2])] then c:put(p[1], p[2], LEAF[6], ltok) end end
-- cool reflected rim on the lower edge, pale torn tissue on the ripped ends
lm:edge():each(function(x, y) local k = K(x, y) if LS[k] and LS[k] > 0.7 and LT[k] > 0.06 and LT[k] < 0.94 and not bias[k] then c:put(x, y, COOL, ltok) end end)
tornE:each(function(x, y) c:put(x, y, (X.hash(x, y, 4) < 0.5) and TORN or LEAF[5], ltok) end)

-- radicle from the sprouting seed, curling over the lower leaf edge (drawn before seed)
local rtok = A.tok("root")
local rm, rn = A.tube({ { 44, 44 }, { 47, 47 }, { 50, 49 }, { 50, 53 } }, function(t) return 1.3 * (1 - t) ^ 0.7 + 0.35 end)
rm:cut(seeds[3].m)
A.shade(c, rm, rn, ROOT, { tok = rtok, cuts = { 0.3, 0.62 }, amb = 0.1 })
rm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not rm:has(x, y) and not seeds[3].m:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)

-- sprout: sheath + two arching strap leaves (rounded tips, channel line)
local stok = A.tok("sprout")
local function strap(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.97 then return -1 end
    local tip = t > 0.82 and sqrt(max(0, 1 - ((t - 0.82) / 0.16) ^ 2)) or 1
    return max(0.3, w * tip)
  end, { fold = 0.35 })
  return m, n, T, S
end
local s1m, s1n, S1T, S1S = strap(40, 37, 36, 24, 25, 14, 1.9)
local s2m, s2n, S2T, S2S = strap(42, 37, 46, 26, 54, 19, 1.7)
s2m:cut(s1m)
local b2 = {} X.ao(b2, s2m, s1m, 1, -1)
A.shade(c, s2m, s2n, LEAF, { tok = stok, bias = b2, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.15 })
A.shade(c, s1m, s1n, LEAF, { tok = stok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.15 })
for _, q in ipairs{ { s1m, S1T, S1S }, { s2m, S2T, S2S } } do
  q[1]:each(function(x, y) local k = K(x, y) if abs(q[3][k]) < 0.16 and q[2][k] > 0.15 and q[2][k] < 0.85 then c:put(x, y, LEAF[2], stok) end end)
end
-- sheath at the base (pink-white, like a clivia leaf base)
local sh = { ".ab.", "abbc", "abcc", ".bc." }
local SC = { a = SHEATH[3], b = SHEATH[2], c = SHEATH[1] }
for j, row in ipairs(sh) do for i = 1, #row do local ch = row:sub(i, i)
  if SC[ch] then c:put(38 + i, 33 + j, SC[ch], stok) end end end

-- seeds last
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  -- slightly angular: flatten one facet (lower-left) by tilting normals
  local tok = A.tok("seed" .. i)
  local n = {}
  vis:each(function(x, y) local k = K(x, y) local nn = s.n[k]
    local f = ((x - s[1]) * 0.6 - (y - s[2]) * 0.8) > s[3] * 0.35 and 0.35 or 0
    n[k] = { A.norm(nn[1] - f * 0.4, nn[2] + f * 0.5, nn[3] + f) } end)
  local idx = A.shade(c, vis, n, SEED, { tok = tok, bias = sb, cuts = { 0.16, 0.32, 0.5, 0.68, 0.85 }, amb = 0.08, wrap = 0.2 })
  -- cool reflected light lower right
  local rim = X.rim(n)
  vis:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.62 and not sb[k] then c:put(x, y, SBNC, tok) end end)
  -- hilum: small dark scar
  local hx, hy = floor(s[1] + s[3] * 0.45 + .5), floor(s[2] + s[4] * 0.35 + .5)
  if vis:has(hx, hy) then c:put(hx, hy, SEED[2], tok) end
  -- specular
  local gx, gy = A.specAt(vis, n, 30)
  if gx then c:put(gx, gy, SEED[6], tok) c:put(gx + 1, gy, SEED[6], tok) end
end
-- quirk: shred of red berry skin on the left seed (glossy, curled edge)
local qk = { ".abb", "abcc", ".cd." }
local QC = { a = RED[4], b = RED[3], c = RED[2], d = RED[1] }
for j, row in ipairs(qk) do for i = 1, #row do local ch = row:sub(i, i)
  if QC[ch] then c:put(14 + i, 39 + j, QC[ch], A.tok("skin")) end end end

A.save(c, NAME)
