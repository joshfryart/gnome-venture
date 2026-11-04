-- raphanobrassica-seed (final, Sonnet high). A cupped, frilly scrap of glaucous blue-green cabbage leaf (thick pale midrib,
-- sparse chalky veins, mealy bloom, ragged torn rim) holding five round hybrid seeds, each split down a seam into a russet-pink
-- radish half and a blue-slate cabbage half with a specular glint and contact shadow. The middle seed has sprouted: a stem
-- that is pink on its lit side and green on its shade side, two notched kidney cotyledons blushed pink at the base, a small
-- radish-style side leaf and the first big ruffled cabbage leaf.
-- quirk: the sprout's stem is two-toned, half radish, half cabbage.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD11_5.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("raphanobrassica-seed")
local LF = { "#1b3b44", "#2a5a58", "#3b7a6c", "#58997f", "#80b99b", "#b2dab6" }
local PINK = { "#4a1a30", "#7e2e48", "#aa4a5c", "#cc6a72", "#e68e8a", "#f8bcb0" }
local BLUE = { "#1f2640", "#35426a", "#4e6490", "#6e86b0", "#94aed0", "#c0d4e8" }
local GRN = { "#1d4a34", "#2c6a40", "#42883f", "#64a64a", "#8cc460", "#b8e08a" }
local COT = { "#24504a", "#2f6e5a", "#40906c", "#5cb07c", "#86cf94", "#b8eab2" }
local MEAL = "#cfe6dc"
local ltok = { r = { name = "leaf" } }

-- ===== seeds
local seeds = {
  { 19, 47, 0.5 }, { 26, 50.5, 1.9 }, { 41, 50.5, 2.6 }, { 47.5, 47, -0.6 },
}
local sprout = { 33.5, 48, 1.2 }
local all = {}
for _, s in ipairs(seeds) do all[#all + 1] = s end
all[#all + 1] = sprout
for _, s in ipairs(all) do s.m, s.n = G.oval(s[1], s[2], 3.4, 3.4, 0, 0.95) end
local rect = HP.mask():add(c:rect(0, 0, 63, 63))
local bias = {}
for _, s in ipairs(all) do X.ao(bias, rect, s.m, 1, -1) G.cast(bias, rect, s.m, 1, 2, -1) end

-- ===== leaf scrap: cupped, frilly
local lw = A.sawW(48, 8.6, { ripple = 1.15, rp = 3.8, pw = 0.5, off = 0.1, k = 0.9, start = 0.0 })
local lm, ln, LT, LS, llen, torn = A.tornBlade(c, 8, 44, 31, 54, 55, 44, lw, {
  ramp = LF, veins = { 0.16, 0.28, 0.4, 0.6, 0.72, 0.84 }, sweep = 3.0, rib = 0.2, ribEnd = 0.96, ribHi = LF[6], fibre = "#e4f0e0",
  cool = "#4a7a9c", bias = bias, veinMax = 0.9, fold = 0.5,
  tear = { [-1] = { depth = 0.55, t0 = 0.03, t1 = 0.32 }, [1] = { depth = 0.45, t0 = 0.72, t1 = 0.97 } } })
-- chalky bloom
lm:each(function(x, y) local k = K(x, y)
  if not bias[k] and X.hash(x, y, 83) > 0.9 and abs(LS[k]) > 0.18 then c:put(x, y, MEAL, ltok) end end)

-- ===== seeds: two halves along a seam
local function twoTone(s, ang)
  local ca, sa = cos(ang), sin(ang)
  local tok = { r = { name = "seed" } }
  local mp, mb = HP.mask(), HP.mask()
  s.m:each(function(x, y)
    local u = (x + 0.5 - s[1]) * ca + (y + 0.5 - s[2]) * sa
    if u < 0 then mp:set(x, y) else mb:set(x, y) end
  end)
  local cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 }
  G.toneN(c, mp, s.n, PINK, { cuts = cuts, tok = tok, amb = 0.08, wrap = 0.25 })
  G.toneN(c, mb, s.n, BLUE, { cuts = cuts, tok = tok, amb = 0.08, wrap = 0.25 })
  -- seam
  s.m:each(function(x, y)
    local u = (x + 0.5 - s[1]) * ca + (y + 0.5 - s[2]) * sa
    if u >= -0.1 and u < 0.9 then c:put(x, y, (u < 0.4) and PINK[1] or BLUE[1], tok) end
  end)
  -- bounce light on the lower-right rim
  local rim = X.rim(s.n)
  s.m:edge():each(function(x, y) end)
  s.m:each(function(x, y) local k = K(x, y)
    if rim[k] and rim[k] > 0.82 then
      local u = (x + 0.5 - s[1]) * ca + (y + 0.5 - s[2]) * sa
      if u < -0.1 then c:put(x, y, PINK[3], tok) elseif u > 0.9 then c:put(x, y, BLUE[3], tok) end
    end
  end)
  local bx, by = G.specAt(s.m, s.n, 34)
  if bx then c:put(bx, by, "#fff4e4", tok) c:put(bx + 1, by, "#e8dcd8", tok) end
end
for i, s in ipairs(seeds) do twoTone(s, s[3]) end
twoTone(sprout, sprout[3])
-- split coat on the sprouting seed
c:put(32, 45, PINK[1]) c:put(33, 45, BLUE[1]) c:put(34, 45, BLUE[1]) c:put(35, 46, BLUE[1])

-- ===== sprout: two-tone stem
local sm, sn, sT, sS = G.tube({ { 33, 47 }, { 32, 39 }, { 34, 30 }, { 33, 23 } }, function(t) return 1.7 - 0.55 * t end)
local v = X.light(sn, { amb = 0.1, wrap = 0.3 })
local mA, mB = HP.mask(), HP.mask()
sm:each(function(x, y) if sS[K(x, y)] < 0.05 then mA:set(x, y) else mB:set(x, y) end end)
X.tone(c, mA, v, PINK, { cuts = { 0.2, 0.36, 0.52, 0.7, 0.86 } })
X.tone(c, mB, v, GRN, { cuts = { 0.12, 0.26, 0.42, 0.62, 0.84 } })
-- seam line between the halves where the pink meets the green
mB:each(function(x, y) if mA:has(x - 1, y) or mA:has(x, y - 1) then c:put(x, y, GRN[1]) end end)

-- ===== cotyledons: notched kidneys
local function cotyl(nx, ny, ang, L, r)
  local m = A.cotMask(nx, ny, ang, L, r)
  local n = X.pillow(m, 2.4)
  local ca, sa = cos(ang), sin(ang)
  local tok = { r = { name = "cot" } }
  G.toneN(c, m, n, COT, { cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 }, tok = tok, amb = 0.1, wrap = 0.25 })
  m:each(function(x, y)
    local u = (x - nx) * ca + (y - ny) * sa
    local w = -(x - nx) * sa + (y - ny) * ca
    if u < 2.6 and abs(w) < 1.8 then c:put(x, y, (w < 0) and PINK[4] or PINK[3], tok)       -- pink blush at the base
    elseif abs(w) < 0.5 and u > 2.6 and u < L - 2.2 then c:put(x, y, (w < 0) and COT[5] or COT[3], tok) end     -- midvein
  end)
  -- cast shadow of the cotyledon on the stem below
  return m
end
cotyl(33, 37.5, pi + 0.3, 12, 3.3)
cotyl(33, 37.5, -0.3, 12, 3.3)
-- upper stem
local sm2, sn2, sT2, sS2 = G.tube({ { 33, 31 }, { 33, 28 }, { 33, 26 }, { 33, 22 } }, function(t) return 1.2 - 0.4 * t end)
local v2 = X.light(sn2, { amb = 0.1, wrap = 0.3 })
local mA2, mB2 = HP.mask(), HP.mask()
sm2:each(function(x, y) if sS2[K(x, y)] < 0.05 then mA2:set(x, y) else mB2:set(x, y) end end)
X.tone(c, mA2, v2, PINK, { cuts = { 0.2, 0.36, 0.52, 0.7, 0.86 } })
X.tone(c, mB2, v2, GRN, { cuts = { 0.12, 0.26, 0.42, 0.62, 0.84 } })

-- ===== leaves: a small side leaf and the first big ruffled one
local function lea(ax, ay, cx, cy, bx, by, w, len, o)
  local W = A.sawW(len, w, { ripple = o.rip, rp = o.rp or 3.4, pw = 0.58, off = 0.1, k = 0.9, start = 0.12 })
  local m, n, T, S = A.tornBlade(c, ax, ay, cx, cy, bx, by, W, {
    ramp = LF, veins = o.veins, sweep = 2.2, rib = o.rib or 0.15, ribEnd = 0.95, ribHi = LF[6], fibre = "#e4f0e0", cool = "#4a7a9c", fold = 0.45 })
  m:each(function(x, y) local k = K(x, y) if T[k] > 0.2 and abs(S[k]) > 0.2 and X.hash(x, y, 84) > 0.9 then c:put(x, y, MEAL, ltok) end end)
  return m
end
lea(33, 26, 25, 21, 18, 20, 3.4, 16, { rip = 0.7, veins = { 0.4, 0.62 } })
lea(33, 24, 32, 14, 46, 11, 6.6, 28, { rip = 1.1, veins = { 0.22, 0.36, 0.5, 0.65, 0.8 }, rib = 0.17 })
A.save(c, "raphanobrassica-seed")
