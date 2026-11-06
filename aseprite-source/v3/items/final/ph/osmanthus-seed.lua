-- osmanthus-seed (final, Opus single pass aC31_3). A torn glossy osmanthus leaf scrap falling on the descending
-- diagonal (narrow elliptic blade, finely toothed margin, waxy specular streak, midrib + veins, cool reflected edge).
-- On it lie a whole ripe drupe (dark violet-blue, olive-shaped, dusty waxy bloom, one bright glint, tiny stalk scar)
-- and a bare cleaned stone (pale tan, longitudinal ridges and grooves). The stone has cracked and sprouted: a slim
-- stem leaning left with two oval seed leaves and a first pair of toothed, pointed osmanthus leaves.
-- quirk: a single tiny orange osmanthus blossom (four petals) has dropped onto the leaf tip.
local NAME = "osmanthus-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC31_3.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new(NAME)

local LEAF = { "#132f2c", "#1d4637", "#2b6242", "#3f7f4a", "#62a058", "#98c878" }
local VEIN, COOL, GLOSS = "#b7d98e", "#346670", "#d6eeb2"
local DRUPE = { "#1c1838", "#2b2556", "#3d3678", "#55509c", "#7a78bc", "#a6a8d8" }
local BLOOM = "#8a8fc4"
local STONE = { "#4e3424", "#74503a", "#9a7352", "#bd986e", "#dcbe90", "#f2dcb0" }
local STEM = { "#3c6a48", "#5f9258", "#8fbc76", "#c6e2a2" }
local FLOW = { "#b4501e", "#e47a24", "#f8a63c", "#ffd27a" }
local CUTS = { 0.22, 0.38, 0.54, 0.7, 0.86 }

-- leaf scrap: base torn at the upper left, tip to the lower right
local lm, ln, LT, LS, len = G.blade(12, 34, 32, 40, 55, 55, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 7.8 * sin(pi * min(1, t * 0.8 + 0.2)) ^ 0.75)
end, { fold = 0.45 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local d, s = LT[k] * len, LS[k]
  -- ragged tear
  local z = 3 + 2.5 * abs(((s * 3.7 + 0.3) % 2) - 1)
  if d < z then cut[#cut + 1] = k end
  -- toothed margin: small notch every 3 px on both edges
  if abs(s) > 0.8 and d > 6 and LT[k] < 0.94 then
    local ph = (d + (s > 0 and 1.5 or 0)) / 3
    if ph - floor(ph) < 0.3 then cut[#cut + 1] = k end
  end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end

-- drupe (whole fruit) and stone (sprouting)
local fr = { 37, 46, 5.0, 3.4, 0.5 }
fr.m, fr.n = G.oval(fr[1], fr[2], fr[3], fr[4], fr[5], 0.9)
local st = { 25, 40, 4.0, 2.5, 0.42 }
st.m, st.n = G.oval(st[1], st[2], st[3], st[4], st[5], 0.8)

-- sprout from the stone, leaning left then up
local sp = { { 23, 38 }, { 20, 30 }, { 19, 22 }, { 22, 13 } }
local sm, sn, ST = G.tube(sp, function(t) return 1.1 - 0.25 * t end)

-- flower (quirk) on the leaf near the tip
local fx, fy = 49, 52
local fl = HP.mask()
for _, q in ipairs{ { -1.6, 0 }, { 1.6, 0 }, { 0, -1.6 }, { 0, 1.6 } } do fl:add(HP.ellipse(fx + q[1], fy + q[2], 1, 1)) end

-- leaf tone, AO + contact shadow under fruit, stone, flower, stem foot
local bias = {}
for _, m in ipairs{ fr.m, st.m } do X.ao(bias, lm, m, 1, -1) G.cast(bias, lm, m, 1, 2, -1) end
G.cast(bias, lm, fl, 1, 1, -1)
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.24, 0.4, 0.55, 0.7, 0.86 }, amb = 0.12, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t > 0.04 and t < 0.92 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 5.5) / 6.0
  if ph - floor(ph) < 0.13 and abs(s) > 0.15 and abs(s) < 0.75 and t > 0.08 and t < 0.86 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
  -- waxy gloss streak on the lit half
  if s < -0.35 and s > -0.6 and t > 0.55 and t < 0.75 then c:put(x, y, GLOSS, ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and LT[k] > 0.12 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)

-- stem behind the stone
local stok = { r = { name = "stem" } }
local smv = sm:copy():cut(st.m)
G.toneN(c, smv, sn, STEM, { tok = stok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })

-- leaves on the sprout
local function sleaf(ax, ay, bx, by, w, bow, teeth)
  local cx, cy = (ax + bx) / 2 + bow, (ay + by) / 2 - 1.2
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.88 + 0.08)) ^ 0.7)
  end, { fold = 0.35 })
  if teeth then
    local cc = {}
    m:each(function(x, y) local k = K(x, y)
      if abs(S[k]) > 0.78 and T[k] > 0.3 and T[k] < 0.9 and ((T[k] * L) % 2.6) < 0.8 then cc[#cc + 1] = k end end)
    for _, k in ipairs(cc) do m.s[k] = nil end
  end
  m:cut(sm)
  return { m = m, n = n, T = T, S = S }
end
local cxm, cym = G.bez(sp, 0.5)
local txm, tym = G.bez(sp, 1)
local lv = {
  sleaf(cxm - 0.5, cym, cxm - 7, cym - 1, 2.0, 0, false),
  sleaf(cxm + 0.5, cym, cxm + 7, cym - 2, 2.0, 0, false),
  sleaf(txm - 0.5, tym + 0.5, txm - 11, tym - 4, 2.9, 0.5, true),
  sleaf(txm + 0.5, tym + 0.5, txm + 11, tym - 6, 2.9, -0.5, true),
}
for i, L in ipairs(lv) do
  local b = {}
  X.ao(b, L.m, sm, 1, -1)
  G.toneN(c, L.m, L.n, LEAF, { tok = ltok, bias = b, cuts = { 0.24, 0.4, 0.55, 0.7, 0.86 }, amb = 0.14, wrap = 0.3 })
  L.m:each(function(x, y) local k = K(x, y) local s, t = L.S[k], L.T[k]
    if not b[k] and abs(s) < 0.15 and t > 0.08 and t < 0.86 then c:put(x, y, s <= 0 and (i > 2 and VEIN or LEAF[6]) or LEAF[3], ltok) end
    if i > 2 and not b[k] and s < -0.3 and s > -0.6 and t > 0.4 and t < 0.6 then c:put(x, y, GLOSS, ltok) end
  end)
end
-- terminal bud
local bud, bdn = G.oval(txm + 0.3, tym - 2, 0.9, 1.6, 0.15, 0.8)
G.toneN(c, bud, bdn, STEM, { tok = stok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.2 })

-- stone: ridged, cracked open at the sprout end
do
  local tok = { r = { name = "stone" } }
  local vis = st.m:copy()
  local sb = {} X.ao(sb, vis, fr.m, 1, -1)
  local ca, sa = cos(st[5]), sin(st[5])
  local v = X.light(st.n, { amb = 0.1, wrap = 0.3 })
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - st[1], y - st[2]
    local u, w = (dx * ca + dy * sa) / (st[3] + .45), (-dx * sa + dy * ca) / (st[4] + .45)
    local i = 1 for j, ct in ipairs(CUTS) do if v[k] >= ct then i = j + 1 end end
    -- longitudinal grooves
    if abs(w - 0.05) < 0.14 or abs(w - 0.62) < 0.12 or abs(w + 0.5) < 0.12 then i = i - 2 end
    i = i + (sb[k] or 0)
    c:put(x, y, STONE[max(1, min(6, i))], tok)
  end)
  -- crack where the stem leaves the stone
  c:put(22, 38, STONE[1], tok) c:put(23, 39, STONE[1], tok) c:put(21, 38, STONE[2], tok)
  local gx, gy = G.specAt(vis, st.n, 30)
  c:put(gx, gy, STONE[6], tok)
end

-- drupe: dark glossy fruit with waxy bloom specks + one bright glint + stalk scar
do
  local tok = { r = { name = "drupe" } }
  G.toneN(c, fr.m, fr.n, DRUPE, { tok = tok, cuts = { 0.14, 0.3, 0.48, 0.66, 0.84 }, amb = 0.08, wrap = 0.3 })
  -- bloom: sparse pale dusting in the mid tones
  fr.m:each(function(x, y) local k = K(x, y)
    if (x * 3 + y * 5) % 7 == 0 and not fr.m:edge():has(x, y) then c:put(x, y, BLOOM, tok) end end)
  -- cool reflected light on the lower right rim
  local rim = X.rim(fr.n)
  fr.m:edge():each(function(x, y) if (rim[K(x, y)] or 0) > 0.55 then c:put(x, y, "#4a5aa0", tok) end end)
  local gx, gy = G.specAt(fr.m, fr.n, 60)
  c:put(gx, gy, "#fff4d6", tok) c:put(gx + 1, gy, "#d8dcf4", tok)
  -- stalk scar at the upper-left end
  local sx, sy = floor(fr[1] - cos(fr[5]) * (fr[3] - 0.5) + 0.5), floor(fr[2] - sin(fr[5]) * (fr[3] - 0.5) + 0.5)
  c:put(sx, sy, DRUPE[1], tok) c:put(sx + 1, sy, "#6b5a3a", tok)
end

-- quirk blossom
do
  local tok = { r = { name = "flower" } }
  local fn = X.pillow(fl, 1.2)
  G.toneN(c, fl, fn, FLOW, { tok = tok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.25 })
  c:put(fx, fy, FLOW[1], tok)
  c:put(fx - 1, fy - 2, FLOW[4], tok)
end

G.save(c, NAME)
