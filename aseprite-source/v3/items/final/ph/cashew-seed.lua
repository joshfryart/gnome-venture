-- cashew-seed (final, Opus single pass). Two raw cashew nuts (olive-khaki kidney shells, raised suture seam, matte
-- speckle, AO + contact shadow) on a torn scrap of leathery cashew leaf (rounded obovate blade, ragged torn base,
-- pinnate veins, V-fold light, cool reflected edge). The right nut has germinated: a pale stem rising from its hollow
-- with two glossy obovate cashew leaves (midrib + veins) and a bronze-pink new bud between them.
-- quirk: the left nut's shell has cracked, and a cream kernel peeks out.
local NAME = "cashew-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r0_5.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local c = A.new(NAME)
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local OLD = { "#1d3a32", "#2a5240", "#3c6c48", "#55884e", "#78a45a", "#a8c47a" } -- older, duller scrap
local NUT = { "#2e2a26", "#4c4434", "#6c6246", "#8e8456", "#b4aa78", "#dcd4a2" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local KER = { "#c9a46a", "#ecd29a", "#fff4d6" }
local COOL = "#3a6c72"

-- nuts: kidney C-shapes, hollow facing up
local n1 = { A.kidney(19, 44, 5.6, 2.2, -0.08, 2.6, 2.1) }
local n2 = { A.kidney(38, 40, 5.4, 2.1, -0.22, 2.6, 2.1) }

-- leaf scrap: obovate blade lying on the diagonal, base torn off
local lm, ln, LT, LS, len = G.blade(7, 53, 30, 52, 56, 37, function(t)
  if t > 0.99 then return -1 end
  return max(0.6, 9.2 * sin(pi * min(1, t ^ 1.25 * 0.92 + 0.12)) ^ 0.55)
end, { fold = 0.4 })
-- torn base: ragged cut across the blade near t~0.1
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local lim = 0.09 + 0.05 * abs(sin(LS[k] * 9.5)) + 0.03 * X.hash(x, y, 5)
  if LT[k] < lim then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, n in ipairs{ n1, n2 } do X.ao(bias, lm, n[1], 1, -1) G.cast(bias, lm, n[1], 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = G.toneN(c, lm, ln, OLD, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t < 0.95 then c:put(x, y, s <= 0 and "#c8dc96" or OLD[3], ltok) return end
  local d = (t * len - abs(s) * 6.5) % 5.2
  if d < 0.85 and abs(s) > 0.18 and abs(s) < 0.82 and t < 0.9 then c:put(x, y, s < 0 and OLD[6] or OLD[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and LT[k] > 0.2 then c:put(x, y, COOL, ltok) end
  if LT[k] < 0.2 then c:put(x, y, "#d6dca0", ltok) end  -- pale torn fibre edge
end)

-- sprout from the right nut's hollow
local stok = { r = { name = "stem" } }
local sm = A.stem(c, { { 38, 39 }, { 37, 33 }, { 39, 27 }, { 38, 21 } }, function(t) return 1.1 - t * 0.15 end, STEM, { tok = stok })
local function sleaf(ax, ay, cx, cy, bx, by, w)
  return A.leaf(c, ax, ay, cx, cy, bx, by, w, LEAF, {
    wfn = function(t) if t > 0.99 then return -1 end return max(0.4, w * sin(pi * min(1, t ^ 1.3 * 0.95 + 0.05)) ^ 0.6) end,
    vs = 2.8, cut = sm })
end
local la = sleaf(37, 23, 30, 16, 21, 17, 3.6)
local lb = sleaf(39, 21, 45, 13, 54, 13, 3.8)
-- bud: bronze-pink young leaf (cashew flush)
local bud = HP.mask() for _, p in ipairs{ { 38, 20 }, { 38, 19 }, { 39, 19 }, { 38, 18 }, { 39, 18 }, { 39, 17 } } do bud:set(p[1], p[2]) end
local btok = { r = { name = "bud" } }
c:put(38, 20, "#8a3a3a", btok) c:put(38, 19, "#c25a48", btok) c:put(39, 19, "#9a4440", btok)
c:put(38, 18, "#e88a6a", btok) c:put(39, 18, "#c25a48", btok) c:put(39, 17, "#e88a6a", btok)

-- nuts
local function nut(n, other, crack)
  local m, nn, T, S = n[1], n[2], n[3], n[4]
  m = m:copy() if other then m:cut(other) end
  local b = {}
  X.ao(b, m, sm, 1, -1)
  local tok = { r = { name = "nut" } }
  local idx = A.shade(c, m, nn, NUT, { amb = 0.1, wrap = 0.3, bias = b, tok = tok })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if s > 0.36 and s < 0.62 and t > 0.12 and t < 0.88 then c:put(x, y, NUT[max(1, idx[k] - 2)], tok)
    elseif X.hash(x, y, 7) < 0.08 and idx[k] >= 3 then c:put(x, y, NUT[idx[k] - 1], tok) end
  end)
  local bx, by = G.specAt(m, nn, 30) c:put(bx, by, NUT[6], tok)
  if crack then
    -- crack on the left lobe: ink-dark split with the cream kernel showing
    local pts = { { 15, 42 }, { 16, 43 }, { 16, 44 }, { 17, 45 } }
    for i, p in ipairs(pts) do if m:has(p[1], p[2]) then c:put(p[1], p[2], NUT[1], tok) end end
    for _, p in ipairs{ { 17, 43, 2 }, { 17, 44, 1 }, { 18, 44, 2 } } do if m:has(p[1], p[2]) then c:put(p[1], p[2], KER[p[3]], tok) end end
    c:put(17, 43, KER[3], tok)
  end
  return m
end
nut(n2, nil, false)
nut(n1, nil, true)
-- stem foot: the stem rises out of the hollow, overlap the nut lip slightly
for _, p in ipairs{ { 38, 38 }, { 37, 38 } } do if n2[1]:has(p[1], p[2]) then c:put(p[1], p[2], STEM[2], stok) end end

A.save(c, NAME)
